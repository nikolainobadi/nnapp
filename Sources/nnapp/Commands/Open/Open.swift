//
//  Open.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import Foundation
import GitShellKit
import SwiftPicker
import ArgumentParser

extension Nnapp {
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open a Project in Xcode/VSCode, open a Project's remote repository, or open a website linked with a Project"
        )
    
        @Argument(help: "The project shortcut.")
        var shortcut: String?
        
        @Flag(help: "Open the project in an IDE (-x for xcode, -v for VSCode) or open a link (-r for remote repository, -l for other links)")
        var launchType: LaunchType = .xcode
        
        // TODO: - might want to change the flag name
        @Flag(name: .customShort("o"), help: "Opens the list of projects within the group associated with the shortcut provided")
        var useGroupShortcut: Bool = false

        func run() throws {
            let project = try selectProject(shortcut: shortcut, useGroupShortcut: useGroupShortcut)
            
            switch launchType {
            case .xcode, .vscode:
                try openInIDE(project, isXcode: launchType == .xcode)
            case .remote:
                guard let remote = project.remote else {
                    print("\(project.name) doesn't have a remote repository registered")
                    return
                }
                
                print("opening \(remote.name), url: \(remote.urlString)")
                try shell.runAndPrint("open \(remote.urlString)")
            case .link:
                // TODO: - 
                break
            }
            
            print("Should open \(project.name)")
        }
    }
}


// MARK: - Private Methods
private extension Nnapp.Open {
    func selectProject(shortcut: String?, useGroupShortcut: Bool) throws -> LaunchProject {
        let context = try makeContext()
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
    
    func openInIDE(_ project: LaunchProject, isXcode: Bool) throws {
        guard let folderPath = project.folderPath, let filePath = project.filePath else {
            throw CodeLaunchError.missingProject
        }
        
        try cloneProjectIfNecessary(project, folderPath: folderPath, filePath: filePath)
        openDirectoryInTerminalIfNecessary(folderPath: folderPath)
        try shell.runAndPrint("\(isXcode ? "open" : "code") \(filePath)")
    }
    
    func cloneProjectIfNecessary(_ project: LaunchProject, folderPath: String, filePath: String) throws {
        do {
            // check if folder already exists
            let _ = try Folder(path: folderPath)
        } catch {
            guard let remote = project.remote, let groupPath = project.groupPath, !groupPath.isEmpty else {
                print("cannot locate project \(project.name) and not remote repository exists")
                throw CodeLaunchError.noRemoteRepository
            }
            
            try picker.requiredPermission(prompt: "Unable to locate \(project.fileName.green) at path \(filePath.yellow)\nWould you like to fetch it from \(remote.name.green) - \(remote.urlString.yellow)?")
            
            let cloneCommand = makeGitCommand(.clone(remote.urlString), path: groupPath)
            
            try shell.runAndPrint(cloneCommand)
        }
    }
    
    func openDirectoryInTerminalIfNecessary(folderPath: String) {
        guard let openPaths = try? shell.getITermSessionPaths(), !openPaths.contains(folderPath) else {
            return
        }

        print("preparing to open project in new terminal window")
        var script = "cd \(folderPath)"
            
        if let extraCommand = try? makeContext().loadLaunchScript() {
            script.append(" && \(extraCommand)")
        }
        
        script.append(" && clear")
        
        shell.runScriptInNewTerminalWindow(script: script)
    }
}


// MARK: - Dependencies
public enum LaunchType: String, CaseIterable {
    case xcode, vscode, remote, link
}


// MARK: - Extension Dependencies
extension LaunchType: EnumerableFlag {
    public static func name(for value: LaunchType) -> NameSpecification {
        switch value {
        case .xcode:
            return .customShort("x")
        case .vscode:
            return .customShort("v")
        case .remote:
            return .customShort("r")
        case .link:
            return .customShort("l")
        }
    }
}

extension String {
    func matches(_ value: String?) -> Bool {
        guard let value else {
            return false
        }
        
        return self.lowercased() == value.lowercased()
    }
}

fileprivate extension Shell {
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
            
            let _ = try? runAppleScript(script: appleScript)
        }
    }
    
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
        
        return try runAppleScript(script: script).components(separatedBy: ", ")
    }
}
