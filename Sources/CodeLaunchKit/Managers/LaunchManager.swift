//
//  LaunchManager.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public struct LaunchManager: LaunchService {
    private let loader: any Loader
    private let delegate: any LaunchDelegate

    public typealias Loader = ScriptLoader & LaunchHierarchyLoader

    public init(loader: any Loader, delegate: any LaunchDelegate) {
        self.loader = loader
        self.delegate = delegate
    }
}


// MARK: - Project Selection
public extension LaunchManager {
    func resolveProject(shortcut: String?, useGroupShortcut: Bool) throws -> LaunchProject {
        guard let shortcut else {
            throw CodeLaunchError.missingProject
        }

        if useGroupShortcut {
            let groups = try loader.loadGroups()
            guard let group = groups.first(where: { shortcut.matches($0.shortcut) }) else {
                throw CodeLaunchError.missingGroup
            }

            guard let project = group.projects.first else {
                throw CodeLaunchError.missingProject
            }

            if group.projects.count == 1 {
                return project
            }

            // Defer specific project selection to the caller (CLI) if multiple exist
            throw CodeLaunchError.missingProject
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
public extension LaunchManager {
    func openInIDE(_ project: LaunchProject, launchType: LaunchType, terminalOption: TerminalOption?) throws {
        guard let folderPath = project.folderPath else {
            throw CodeLaunchError.missingProject
        }

        try delegate.openIDE(project, launchType: launchType)
        delegate.openTerminal(folderPath: folderPath, option: terminalOption)

        if let status = delegate.checkBranchStatus(for: project) {
            delegate.notifyBranchStatus(status, for: project)
        }
    }
}


// MARK: - URL Operations
public extension LaunchManager {
    func openRemoteURL(for project: LaunchProject) throws {
        try delegate.openRemoteURL(for: project.remote)
    }

    func openProjectLink(for project: LaunchProject) throws {
        try delegate.openProjectLink(project.links)
    }
}
