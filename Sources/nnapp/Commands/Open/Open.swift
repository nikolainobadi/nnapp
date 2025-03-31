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

/// Opens a project in an IDE, terminal, or browser — depending on the selected launch type.
/// Supports quick-launching by project or group shortcut.
extension Nnapp {
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open a Project in Xcode/VSCode, open a Project's remote repository, or open a website linked with a Project"
        )

        /// The shortcut used to identify the project or group to open.
        @Argument(help: "The project shortcut.")
        var shortcut: String?

        /// The desired launch type (IDE, remote URL, or custom link).
        @Flag(help: "Open the project in an IDE (-x for xcode, -v for VSCode) or open a link (-r for remote repository, -l for other links)")
        var launchType: LaunchType = .xcode

        /// Indicates whether to use the group shortcut instead of a project shortcut.
        @Flag(name: .customShort("g"), help: "Opens the list of projects within the group associated with the shortcut provided")
        var useGroupShortcut: Bool = false

        /// Controls terminal launch behavior (open, skip, or only open terminal).
        @Flag(help: "-n only launches the project, -t only launches terminal. Don't include to launch and open terminal. Only applies to opening in Xcode/VSCode")
        var terminalOption: TerminalOption?

        func run() throws {
            let context = try Nnapp.makeContext()
            let project = try selectProject(shortcut: shortcut, useGroupShortcut: useGroupShortcut, context: context)

            switch launchType {
            case .xcode, .vscode:
                try openInIDE(project, isXcode: launchType == .xcode, terminalOption: terminalOption, context: context)
            case .remote:
                try openRemoteURL(for: project)
            case .link:
                try openProjectLink(for: project)
            }
        }
    }
}


// MARK: - Private Helpers
private extension Nnapp.Open {
    var shell: Shell {
        return Nnapp.makeShell()
    }

    var picker: Picker {
        return Nnapp.makePicker()
    }

    /// Resolves a `LaunchProject` using either a shortcut or interactive selection.
    func selectProject(shortcut: String?, useGroupShortcut: Bool, context: CodeLaunchContext) throws -> LaunchProject {
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


// MARK: - Launch
private extension Nnapp.Open {
    /// Opens the project in Xcode or VSCode, optionally launching terminal in the project directory.
    func openInIDE(_ project: LaunchProject, isXcode: Bool, terminalOption: TerminalOption?, context: CodeLaunchContext) throws {
        guard let folderPath = project.folderPath,
              let filePath = project.filePath else {
            throw CodeLaunchError.missingProject
        }

        try cloneProjectIfNecessary(project, folderPath: folderPath, filePath: filePath)
        openDirectoryInTerminalIfNecessary(folderPath: folderPath, terminalOption: terminalOption, context: context)

        if let terminalOption, terminalOption == .onlyTerminal {
            return
        }

        try shell.runAndPrint("\(isXcode ? "open" : "code") \(filePath)")
    }

    /// Clones the project repo if it doesn’t exist locally and a remote is available.
    func cloneProjectIfNecessary(_ project: LaunchProject, folderPath: String, filePath: String) throws {
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

            let cloneCommand = makeGitCommand(.clone(remote.urlString), path: groupPath)
            try shell.runAndPrint(cloneCommand)
        }
    }

    /// Opens the project folder in a new terminal window, if not already open.
    func openDirectoryInTerminalIfNecessary(folderPath: String, terminalOption: TerminalOption?, context: CodeLaunchContext) {
        if let terminalOption, terminalOption == .noTerminal {
            return
        }

        guard let openPaths = try? shell.getITermSessionPaths(),
              !openPaths.contains(folderPath) else {
            return
        }

        print("preparing to open project in new terminal window")
        var script = "cd \(folderPath)"

        if let extraCommand = context.loadLaunchScript() {
            script.append(" && \(extraCommand)")
        }

        script.append(" && clear")
        shell.runScriptInNewTerminalWindow(script: script)
    }
}


// MARK: - Open URL
private extension Nnapp.Open {
    /// Opens the remote repository URL in the browser.
    func openRemoteURL(for project: LaunchProject) throws {
        guard let remote = project.remote else {
            print("\(project.name) doesn't have a remote repository registered")
            throw CodeLaunchError.missingGitRepository
        }

        print("opening \(remote.name), url: \(remote.urlString)")
        try shell.runAndPrint("open \(remote.urlString)")
    }

    /// Opens one of the project's custom links, prompting if multiple exist.
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


// MARK: - Dependencies
/// Controls whether to open the terminal, skip it, or launch it only.
enum TerminalOption: String, CaseIterable {
    case noTerminal
    case onlyTerminal
}

/// The type of action to perform when opening a project.
public enum LaunchType: String, CaseIterable {
    case xcode
    case vscode
    case remote
    case link

    var argChar: Character {
        switch self {
        case .xcode: return "x"
        case .vscode: return "v"
        case .remote: return "r"
        case .link: return "l"
        }
    }
}

extension LaunchType: EnumerableFlag {
    public static func name(for value: LaunchType) -> NameSpecification {
        return .customShort(value.argChar)
    }
}

extension TerminalOption: EnumerableFlag {
    public static func name(for value: TerminalOption) -> NameSpecification {
        switch value {
        case .noTerminal: return [.customShort("n"), .customLong("no-terminal")]
        case .onlyTerminal: return [.customShort("t"), .customLong("terminal")]
        }
    }
}

/// Returns `true` if the string matches another value, case-insensitively.
/// - Parameter value: The optional string to compare against.
/// - Returns: `true` if both strings match when lowercased; otherwise, `false`.
extension String {
    func matches(_ value: String?) -> Bool {
        guard let value else {
            return false
        }

        return self.lowercased() == value.lowercased()
    }
}

fileprivate extension Shell {
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

            let _ = try? runAppleScript(script: appleScript)
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

        return try runAppleScript(script: script).components(separatedBy: ", ")
    }
}
