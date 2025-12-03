//
//  OpenProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import SwiftPickerKit

/// Coordinates project opening operations by delegating to specialized components.
struct OpenProjectHandler {
    private let picker: any CommandLinePicker
    private let context: CodeLaunchContext
    private let ideLauncher: IDELauncher
    private let terminalManager: TerminalManager
    private let urlLauncher: URLLauncher
    private let branchSyncChecker: any BranchSyncChecker
    private let branchStatusNotifier: any BranchStatusNotifier

    /// Initializes a new handler for project opening operations.
    /// - Parameters:
    ///   - picker: Utility for prompting user input and selections.
    ///   - context: Data context for loading projects and configurations.
    ///   - ideLauncher: Component for launching IDEs and cloning projects.
    ///   - terminalManager: Component for terminal operations.
    ///   - urlLauncher: Component for opening URLs and links.
    ///   - branchSyncChecker: Component for checking branch sync status.
    ///   - branchStatusNotifier: Component for notifying about branch status.
    init(picker: any CommandLinePicker, context: CodeLaunchContext, ideLauncher: IDELauncher, terminalManager: TerminalManager, urlLauncher: URLLauncher, branchSyncChecker: any BranchSyncChecker, branchStatusNotifier: any BranchStatusNotifier) {
        self.picker = picker
        self.context = context
        self.ideLauncher = ideLauncher
        self.terminalManager = terminalManager
        self.urlLauncher = urlLauncher
        self.branchSyncChecker = branchSyncChecker
        self.branchStatusNotifier = branchStatusNotifier
    }
}


// MARK: - Project Selection
extension OpenProjectHandler {
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
extension OpenProjectHandler {
    /// Opens the project in Xcode or VSCode, optionally launching terminal in the project directory.
    /// - Parameters:
    ///   - project: The project to open.
    ///   - launchType: Whether to open in Xcode or VSCode.
    ///   - terminalOption: Controls terminal launch behavior.
    func openInIDE(_ project: LaunchProject, launchType: LaunchType, terminalOption: TerminalOption?) throws {
        guard let folderPath = project.folderPath else {
            throw CodeLaunchError.missingProject
        }

        try ideLauncher.openInIDE(project, launchType: launchType)
        terminalManager.openDirectoryInTerminal(folderPath: folderPath, terminalOption: terminalOption)

        if let status = branchSyncChecker.checkBranchSyncStatus(for: project) {
            branchStatusNotifier.notify(status: status, for: project)
        }
    }
}


// MARK: - URL Operations
extension OpenProjectHandler {
    /// Opens the remote repository URL in the browser.
    /// - Parameter project: The project whose remote URL to open.
    func openRemoteURL(for project: LaunchProject) throws {
        try urlLauncher.openRemoteURL(remote: project.remote)
    }

    /// Opens one of the project's custom links, prompting if multiple exist.
    /// - Parameter project: The project whose link to open.
    func openProjectLink(for project: LaunchProject) throws {
        try urlLauncher.openProjectLink(links: project.links)
    }
}


// MARK: - Dependencies
enum LaunchBranchStatus {
    case behind, diverged
}

protocol BranchSyncChecker {
    func checkBranchSyncStatus(for project: LaunchProject) -> LaunchBranchStatus?
}

protocol BranchStatusNotifier {
    func notify(status: LaunchBranchStatus, for project: LaunchProject)
}
