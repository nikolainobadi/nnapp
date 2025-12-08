//
//  ProjectInfoSelector.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct ProjectInfoSelector {
    private let shell: any LaunchShell
    private let picker: any LaunchPicker
    private let infoLoader: any ProjectInfoLoader
    private let projectService: any ProjectService

    init(
        shell: any LaunchShell,
        picker: any LaunchPicker,
        infoLoader: any ProjectInfoLoader,
        projectService: any ProjectService
    ) {
        self.shell = shell
        self.picker = picker
        self.infoLoader = infoLoader
        self.projectService = projectService
    }
}


// MARK: - Action
extension ProjectInfoSelector {
    /// Prompts the user for project info (name, shortcut, remote, links) using the folder and group context.
    /// - Parameters:
    ///   - folder: The selected folder to create the project from.
    ///   - shortcut: Optional pre-defined shortcut.
    ///   - group: The group this project will belong to.
    ///   - isMainProject: Indicates whether this project is the group's primary launch target.
    /// - Returns: A `ProjectInfo` struct with the collected input.
    func selectProjectInfo(folder: Directory, shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> ProjectInfo {
        try validateName(folder.name)
        let shortcut = try getShortcut(shortcut: shortcut, group: group, isMainProject: isMainProject)
        try validateShortcut(shortcut)
        let remote = getRemote(folder: folder)
        let otherLinks = getOtherLinks()

        return .init(name: folder.name, shortcut: shortcut, remote: remote, otherLinks: otherLinks)
    }
}


// MARK: - Private Methods
private extension ProjectInfoSelector {
    func validateName(_ name: String) throws {
        let projects = try infoLoader.loadProjects()

        _ = try projectService.validateName(name, projects: projects)
    }

    func validateShortcut(_ shortcut: String?) throws {
        let groups = try infoLoader.loadGroups()
        let projects = groups.flatMap({ $0.projects })

        _ = try projectService.validateShortcut(shortcut, groups: groups, projects: projects)
    }
    
    func getShortcut(shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> String? {
        if let shortcut { return shortcut }

        let prompt = "Enter the shortcut to launch this project."

        if group.shortcut != nil && !isMainProject {
            guard picker.getPermission("Would you like to add a quick-launch shortcut for this project?") else {
                return nil
            }
        }

        return try picker.getRequiredInput(prompt)
    }

    func getRemote(folder: Directory) -> ProjectLink? {
        guard let githubURL = try? shell.getGitHubURL(at: folder.path),
              picker.getPermission("Is this the correct remote url: \(githubURL)?") else {
            return nil
        }

        // TODO: - will need to expand support for other websites
        return .init(name: "GitHub", urlString: githubURL)
    }

    /// Launches a prompt flow for adding additional custom links (e.g. Firebase, website).
    func getOtherLinks() -> [ProjectLink] {
        let linkOptions = projectService.loadProjectLinkNames()
        let handler = ProjectLinkSelector(picker: picker, linkOptions: linkOptions, projectService: projectService)
        
        return handler.getOtherLinks()
    }
}
