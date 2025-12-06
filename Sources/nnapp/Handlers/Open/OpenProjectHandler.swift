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
    private let loader: any Loader
    private let service: any ProjectOpenServing

    typealias Loader = LaunchHierarchyLoader & ScriptLoader
    init(
        shell: any LaunchGitShell,
        picker: any LaunchPicker,
        loader: any Loader,
        fileSystem: any FileSystem
    ) {
        self.picker = picker
        self.loader = loader
        self.service = DefaultProjectOpenService(
            shell: shell,
            picker: picker,
            loader: loader,
            fileSystem: fileSystem
        )
    }

    init(
        picker: any LaunchPicker,
        loader: any Loader,
        service: any ProjectOpenServing
    ) {
        self.picker = picker
        self.loader = loader
        self.service = service
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
            throw CodeLaunchError.missingProject
        }

        try service.openIDE(project, launchType: launchType)
        service.openTerminal(folderPath: folderPath, option: terminalOption)

        if let status = service.checkBranchStatus(for: project) {
            service.notifyBranchStatus(status, for: project)
        }
    }
}


// MARK: - URL Operations
extension OpenProjectHandler {
    /// Opens the remote repository URL in the browser.
    /// - Parameter project: The project whose remote URL to open.
    func openRemoteURL(for project: LaunchProject) throws {
        try service.openRemoteURL(for: project.remote)
    }

    /// Opens one of the project's custom links, prompting if multiple exist.
    /// - Parameter project: The project whose link to open.
    func openProjectLink(for project: LaunchProject) throws {
        try service.openProjectLink(project.links)
    }
}


// MARK: - Dependencies
enum LaunchBranchStatus {
    case behind, diverged
}

protocol ProjectOpenServing {
    func openIDE(_ project: LaunchProject, launchType: LaunchType) throws
    func openTerminal(folderPath: String, option: TerminalOption?)
    func checkBranchStatus(for project: LaunchProject) -> LaunchBranchStatus?
    func notifyBranchStatus(_ status: LaunchBranchStatus, for project: LaunchProject)
    func openRemoteURL(for remote: ProjectLink?) throws
    func openProjectLink(_ links: [ProjectLink]) throws
}

struct DefaultProjectOpenService: ProjectOpenServing {
    private let ideLauncher: IDEHandler
    private let terminalManager: TerminalHandler
    private let urlLauncher: URLHandler
    private let branchSyncChecker: BranchSyncChecker
    private let branchStatusNotifier: BranchStatusNotifier

    init(
        shell: any LaunchGitShell,
        picker: any LaunchPicker,
        loader: any OpenProjectHandler.Loader,
        fileSystem: any FileSystem
    ) {
        self.ideLauncher = .init(shell: shell, picker: picker, fileSystem: fileSystem)
        self.terminalManager = .init(shell: shell, loader: loader)
        self.urlLauncher = .init(shell: shell, picker: picker)
        self.branchSyncChecker = .init(shell: shell, fileSystem: fileSystem)
        self.branchStatusNotifier = .init(shell: shell)
    }

    func openIDE(_ project: LaunchProject, launchType: LaunchType) throws {
        try ideLauncher.openInIDE(project, launchType: launchType)
    }

    func openTerminal(folderPath: String, option: TerminalOption?) {
        terminalManager.openDirectoryInTerminal(folderPath: folderPath, terminalOption: option)
    }

    func checkBranchStatus(for project: LaunchProject) -> LaunchBranchStatus? {
        return branchSyncChecker.checkBranchSyncStatus(for: project)
    }

    func notifyBranchStatus(_ status: LaunchBranchStatus, for project: LaunchProject) {
        branchStatusNotifier.notify(status: status, for: project)
    }

    func openRemoteURL(for remote: ProjectLink?) throws {
        try urlLauncher.openRemoteURL(remote: remote)
    }

    func openProjectLink(_ links: [ProjectLink]) throws {
        try urlLauncher.openProjectLink(links: links)
    }
}
