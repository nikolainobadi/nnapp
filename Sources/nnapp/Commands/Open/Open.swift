//
//  Open.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

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
            // TODO: - 
//            let openManager = try Nnapp.makeOpenManager()
//            let project = try openManager.selectProject(shortcut: shortcut, useGroupShortcut: useGroupShortcut)
//
//            switch launchType {
//            case .xcode, .vscode:
//                try openManager.openInIDE(project, launchType: launchType, terminalOption: terminalOption)
//            case .remote:
//                try openManager.openRemoteURL(for: project)
//            case .link:
//                try openManager.openProjectLink(for: project)
//            }
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
