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
    private let infoLoader: any LaunchProjectInfoLoader

    init(shell: any LaunchShell, picker: any LaunchPicker, infoLoader: any LaunchProjectInfoLoader) {
        self.shell = shell
        self.picker = picker
        self.infoLoader = infoLoader
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
    func selectProjectInfo(folder: Directory, shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> LaunchProjectInfo {
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
    /// Ensures the project name is unique within the persistence context.
    func validateName(_ name: String) throws {
        let projects = try infoLoader.loadProjects()

        if projects.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.projectNameTaken
        }
    }

    /// Ensures the provided shortcut doesn't conflict with any existing group or project.
    func validateShortcut(_ shortcut: String?) throws {
        if let shortcut {
            let groups = try infoLoader.loadGroups()
            let projects = groups.flatMap({ $0.projects })
            let allShortcuts = groups.compactMap({ $0.shortcut }) + projects.compactMap({ $0.shortcut })

            if allShortcuts.contains(where: { $0.matches(shortcut) }) {
                throw CodeLaunchError.shortcutTaken
            }
        }
    }
    
    /// Prompts for or determines the project shortcut, optionally syncing with the group shortcut.
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

    /// Retrieves the remote GitHub URL for the folder, if available and confirmed by the user.
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
        let linkOptions = infoLoader.loadProjectLinkNames()
        let handler = ProjectLinkHandler(picker: picker, linkOptions: linkOptions)
        
        return handler.getOtherLinks()
    }
}
