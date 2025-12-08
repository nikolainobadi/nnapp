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
            let projects = try groupProjects(shortcut: shortcut)
            guard let project = projects.first else {
                throw CodeLaunchError.missingProject
            }

            if projects.count > 1 {
                throw CodeLaunchError.missingProject
            }

            return project
        } else {
            let projects = try loader.loadProjects()

            guard let project = projects.first(where: { shortcut.matches($0.shortcut) }) else {
                throw CodeLaunchError.missingProject
            }

            return project
        }
    }

    func groupProjects(shortcut: String) throws -> [LaunchProject] {
        let groups = try loader.loadGroups()
        guard let group = groups.first(where: { shortcut.matches($0.shortcut) }) else {
            throw CodeLaunchError.missingGroup
        }

        return group.projects
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
