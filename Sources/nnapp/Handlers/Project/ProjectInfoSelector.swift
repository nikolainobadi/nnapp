//
//  ProjectInfoSelector.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Files
import SwiftPicker
import GitShellKit

struct ProjectInfoSelector {
    private let picker: Picker
    private let gitShell: GitShell
    private let context: CodeLaunchContext
    
    init(picker: Picker, gitShell: GitShell, context: CodeLaunchContext) {
        self.picker = picker
        self.gitShell = gitShell
        self.context = context
    }
}


// MARK: - Action
extension ProjectInfoSelector {
    func selectProjectInfo(folder: Folder, shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> ProjectInfo {
        try validateName(folder.name)
        let shortcut = try getShortcut(shortcut: shortcut, group: group, isMainProject: isMainProject)
        try validateShortcut(shortcut)
        let remote = getRemote(folder: folder)
        let otherLinks = getOtherLinks()
        
        return .init(name: folder.name, shortcut: shortcut, remote: remote, otherLinks: otherLinks)
    }
}


// MARK: - Validation
private extension ProjectInfoSelector {
    func validateName(_ name: String) throws {
        let projects = try context.loadProjects()
        
        if projects.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.projectNameTaken
        }
    }
    
    func validateShortcut(_ shortcut: String?) throws {
        if let shortcut {
            let groups = try context.loadGroups()
            let projects = groups.flatMap({ $0.projects })
            let allShortcuts = groups.compactMap({ $0.shortcut }) + projects.compactMap({ $0.shortcut })
            
            if allShortcuts.contains(where: { $0.matches(shortcut) }) {
                throw CodeLaunchError.shortcutTaken
            }
        }
    }
}


// MARK: - Private Methods
private extension ProjectInfoSelector {
    func getShortcut(shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> String? {
        if let shortcut {
            return shortcut
        }
        
        let prompt = "Enter the shortcut to launch this project."
        
        if group.shortcut != nil && !isMainProject {
            guard picker.getPermission("Would you like to add a quick-launch shortcut for this project?") else {
                return nil
            }
        }
        
        return try picker.getRequiredInput(prompt)
    }
    
    func getRemote(folder: Folder) -> ProjectLink? {
        guard let githubURL = try? gitShell.getGitHubURL(at: folder.path), picker.getPermission("Is this the correct remote url: \(githubURL)?") else {
            return nil
        }
        
        // TODO: - will need to expand support for other websites
        return .init(name: "GitHub", urlString: githubURL)
    }
    
    func getOtherLinks() -> [ProjectLink] {
        let linkOptions = context.loadProjectLinkNames()
        let handler = ProjectLinkHandler(picker: picker, linkOptions: linkOptions)
        
        return handler.getOtherLinks()
    }
}
