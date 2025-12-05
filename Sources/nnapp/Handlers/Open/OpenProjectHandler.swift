//
//  OpenProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import CodeLaunchKit

/// Coordinates project opening operations by delegating to specialized components.
struct OpenProjectHandler {
    private let picker: any LaunchPicker
    private let loader: any LaunchHierarchyLoader
    private let ideLauncher: IDELauncher
    private let terminalManager: TerminalHandler
    private let urlLauncher: URLLauncher
    private let branchSyncChecker: any BranchSyncChecker
    private let branchStatusNotifier: any BranchStatusNotifier

    typealias Loader = LaunchHierarchyLoader & ScriptLoader
    init(
        shell: any LaunchShell,
        picker: any LaunchPicker,
        loader: any Loader,
        branchSyncChecker: any BranchSyncChecker,
        branchStatusNotifier: any BranchStatusNotifier,
        fileSystem: any FileSystem
    ) {
        self.picker = picker
        self.loader = loader
        self.ideLauncher = .init(shell: shell, picker: picker, fileSystem: fileSystem)
        self.terminalManager = .init(shell: shell, loader: loader)
        self.urlLauncher = .init(shell: shell, picker: picker)
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
            let groups = try loader.loadGroups()
            guard let group = groups.first(where: { shortcut.matches($0.shortcut) }) else {
                throw CodeLaunchError.missingGroup
            }
            
            return try picker.requiredSingleSelection("Select a project", items: group.projects)
        } else {
            let projects = try loader.loadProjects()
            
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
            print("fuck you")
            throw CodeLaunchError.missingProject
        }

        try ideLauncher.openInIDE(project, launchType: launchType)
        terminalManager.openDirectoryInTerminal(folderPath: folderPath, terminalOption: terminalOption)

        if let status = branchSyncChecker.checkBranchSyncStatus(for: project) {
            print("found status, preparing to notify")
            branchStatusNotifier.notify(status: status, for: project)
        } else {
            print("\(project.name) is up to date")
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
