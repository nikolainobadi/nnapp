//
//  LaunchController.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import CodeLaunchKit

struct LaunchController {
    private let picker: any LaunchPicker
    private let launchService: any LaunchService

    init(picker: any LaunchPicker, launchService: any LaunchService) {
        self.picker = picker
        self.launchService = launchService
    }
}


// MARK: - Project Selection
extension LaunchController {
    /// Resolves a `LaunchProject` using either a shortcut or interactive selection.
    /// - Parameters:
    ///   - shortcut: Optional shortcut to identify the project or group.
    ///   - useGroupShortcut: Whether to treat the shortcut as a group identifier.
    /// - Returns: The selected `LaunchProject`.
    func selectProject(shortcut: String?, useGroupShortcut: Bool) throws -> LaunchProject {
        let shortcut = try shortcut ?? picker.getRequiredInput("Enter the shortcut of the app you would like to open")
        
        if useGroupShortcut {
            let projects = try launchService.groupProjects(shortcut: shortcut)
            return try picker.requiredSingleSelection("Select a project", items: projects)
        } else {
            return try launchService.resolveProject(shortcut: shortcut, useGroupShortcut: false)
        }
    }
}


// MARK: - IDE Operations
extension LaunchController {
    /// Opens the project in Xcode or VSCode, optionally launching terminal in the project directory.
    /// - Parameters:
    ///   - project: The project to open.
    ///   - launchType: Whether to open in Xcode or VSCode.
    ///   - terminalOption: Controls terminal launch behavior.
    func openInIDE(_ project: LaunchProject, launchType: LaunchType, terminalOption: TerminalOption?) throws {
        try launchService.openInIDE(project, launchType: launchType, terminalOption: terminalOption)
    }
}


// MARK: - URL Operations
extension LaunchController {
    /// Opens the remote repository URL in the browser.
    /// - Parameter project: The project whose remote URL to open.
    func openRemoteURL(for project: LaunchProject) throws {
        try launchService.openRemoteURL(for: project)
    }

    /// Opens one of the project's custom links, prompting if multiple exist.
    /// - Parameter project: The project whose link to open.
    func openProjectLink(for project: LaunchProject) throws {
        try launchService.openProjectLink(for: project)
    }
}
