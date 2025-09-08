//
//  OpenManager.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import Foundation
import GitShellKit
import SwiftPicker

/// Manages the logic for opening projects in various ways (IDE, terminal, browser).
struct OpenManager {
    private let shell: Shell
    private let picker: CommandLinePicker
    private let context: CodeLaunchContext
    
    /// Initializes a new manager for handling project opening operations.
    /// - Parameters:
    ///   - shell: Shell protocol for executing system commands.
    ///   - picker: Utility for prompting user input and selections.
    ///   - context: Data context for loading projects and configurations.
    init(shell: Shell, picker: CommandLinePicker, context: CodeLaunchContext) {
        self.shell = shell
        self.picker = picker
        self.context = context
    }
}


// MARK: - Project Selection
extension OpenManager {
    /// Resolves a `LaunchProject` using either a shortcut or interactive selection.
    /// - Parameters:
    ///   - shortcut: Optional shortcut to identify the project or group.
    ///   - useGroupShortcut: Whether to treat the shortcut as a group identifier.
    /// - Returns: The selected `LaunchProject`.
    func selectProject(shortcut: String?, useGroupShortcut: Bool) throws -> LaunchProject {
        let shortcut = try shortcut ?? picker.getRequiredInput("Enter the shortcut of the app you would like to open")
        
        if useGroupShortcut {
            let groups = try context.loadGroups()
            guard let group = groups.first(where: { shortcut.matches($0.shortcut) }) else {
                throw CodeLaunchError.missingGroup
            }
            
            return try picker.requiredSingleSelection("Select a project", items: group.projects)
        } else {
            let projects = try context.loadProjects()
            
            guard let project = projects.first(where: { shortcut.matches($0.shortcut) }) else {
                throw CodeLaunchError.missingProject
            }
            
            return project
        }
    }
}


// MARK: - IDE Operations
extension OpenManager {
    /// Opens the project in Xcode or VSCode, optionally launching terminal in the project directory.
    /// - Parameters:
    ///   - project: The project to open.
    ///   - launchType: Whether to open in Xcode or VSCode.
    ///   - terminalOption: Controls terminal launch behavior.
    func openInIDE(_ project: LaunchProject, launchType: LaunchType, terminalOption: TerminalOption?) throws {
        
        guard let folderPath = project.folderPath, let filePath = project.filePath else {
            throw CodeLaunchError.missingProject
        }
        
        try cloneProjectIfNecessary(project, folderPath: folderPath, filePath: filePath)
        openDirectoryInTerminalIfNecessary(folderPath: folderPath, terminalOption: terminalOption)
        
        if let terminalOption, terminalOption == .onlyTerminal {
            return
        }
        
        let isXcode = launchType == .xcode
        try shell.runAndPrint("\(isXcode ? "open" : "code") \(isXcode ? filePath : folderPath)")
    }
    
    /// Clones the project repo if it doesn't exist locally and a remote is available.
    private func cloneProjectIfNecessary(_ project: LaunchProject, folderPath: String, filePath: String) throws {
        do {
            _ = try Folder(path: folderPath) // already exists
        } catch {
            guard let remote = project.remote,
                  let groupPath = project.groupPath,
                  !groupPath.isEmpty else {
                print("cannot locate project \(project.name) and no remote repository exists")
                throw CodeLaunchError.noRemoteRepository
            }
            
            try picker.requiredPermission(prompt: """
            Unable to locate \(project.fileName.green) at path \(filePath.yellow)
            Would you like to fetch it from \(remote.name.green) - \(remote.urlString.yellow)?
            """)
            
            let cloneCommand = makeGitCommand(.clone(url: remote.urlString), path: groupPath)
            try shell.runAndPrint(cloneCommand)
        }
    }
    
    /// Opens the project folder in a new terminal window, if not already open.
    private func openDirectoryInTerminalIfNecessary(folderPath: String, terminalOption: TerminalOption?) {
        if let terminalOption, terminalOption == .noTerminal {
            return
        }
        
        guard let openPaths = try? getITermSessionPaths(),
              !openPaths.contains(folderPath) else {
            return
        }
        
        print("preparing to open project in new terminal window")
        var script = "cd \(folderPath)"
        
        if let extraCommand = context.loadLaunchScript() {
            script.append(" && \(extraCommand)")
        }
        
        script.append(" && clear")
        runScriptInNewTerminalWindow(script: script)
    }
}


// MARK: - URL Operations
extension OpenManager {
    /// Opens the remote repository URL in the browser.
    /// - Parameter project: The project whose remote URL to open.
    func openRemoteURL(for project: LaunchProject) throws {
        guard let remote = project.remote else {
            print("\(project.name) doesn't have a remote repository registered")
            throw CodeLaunchError.missingGitRepository
        }
        
        print("opening \(remote.name), url: \(remote.urlString)")
        try shell.runAndPrint("open \(remote.urlString)")
    }
    
    /// Opens one of the project's custom links, prompting if multiple exist.
    /// - Parameter project: The project whose link to open.
    func openProjectLink(for project: LaunchProject) throws {
        let links = project.links
        var selection: ProjectLink?
        
        switch links.count {
        case 0:
            break
        case 1:
            selection = links.first
            try shell.runAndPrint("open \(links.first!.urlString)")
        default:
            selection = try picker.requiredSingleSelection("Select a link to open", items: links)
        }
        
        if let selection {
            try shell.runAndPrint("open \(selection.urlString)")
        } else {
            print("\(project.name) doesn't have any links")
            throw CodeLaunchError.missingProjectLink
        }
    }
}


// MARK: - Terminal Integration
private extension OpenManager {
    /// Runs the given shell script in a new iTerm tab, if iTerm is available.
    /// - Parameter script: A shell command string to execute.
    func runScriptInNewTerminalWindow(script: String) {
        if let termProgram = ProcessInfo.processInfo.environment["TERM_PROGRAM"], termProgram == "iTerm.app" {
            let appleScript = """
                tell application "iTerm"
                    activate
                    tell current window
                        create tab with default profile
                        tell current session of current tab to write text "\(script)"
                    end tell
                end tell
                """
            
            let _ = try? shell.runAppleScript(script: appleScript)
        }
    }
    
    /// Retrieves all session working directory paths currently open in iTerm.
    /// - Returns: An array of folder paths for open terminal sessions.
    func getITermSessionPaths() throws -> [String] {
        let script = """
        tell application "iTerm"
            set sessionPaths to {}
            repeat with aWindow in windows
                repeat with aTab in tabs of aWindow
                    repeat with aSession in sessions of aTab
                        set sessionPath to (variable aSession named "path")
                        if sessionPath is not missing value then
                            set end of sessionPaths to sessionPath
                        end if
                    end repeat
                end repeat
            end repeat
            return sessionPaths
        end tell
        """
        
        return try shell.runAppleScript(script: script).components(separatedBy: ", ")
    }
}
