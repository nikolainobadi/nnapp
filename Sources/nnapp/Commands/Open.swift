//
//  Open.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import CodeLaunchKit
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

        @Flag(name: .customShort("g"), help: "Opens the list of projects within the group associated with the shortcut provided")
        var useGroupShortcut: Bool = false

        @Flag(help: "-n only launches the project, -t only launches terminal. Don't include to launch and open terminal. Only applies to opening in Xcode/VSCode")
        var terminalOption: TerminalOption?

        func run() throws {
            let launchController = try Nnapp.makeLaunchController()
            let project: LaunchProject = try launchController.selectProject(shortcut: shortcut, useGroupShortcut: useGroupShortcut)

            switch launchType {
            case .xcode, .vscode:
                try launchController.openInIDE(project, launchType: launchType, terminalOption: terminalOption)
            case .remote:
                try launchController.openRemoteURL(for: project)
            case .link:
                try launchController.openProjectLink(for: project)
            }
        }
    }
}


// MARK: - Extension Dependencies
extension LaunchType: EnumerableFlag {
    public static func name(for value: LaunchType) -> NameSpecification {
        return .customShort(value.argChar)
    }
}

extension TerminalOption: EnumerableFlag {
    public static func name(for value: TerminalOption) -> NameSpecification {
        switch value {
        case .noTerminal:
            return [.customShort("n"), .customLong("no-terminal")]
        case .onlyTerminal:
            return [.customShort("t"), .customLong("terminal")]
        }
    }
}
