//
//  ProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import Files
import SwiftPicker

struct ProjectHandler {
    private let picker: Picker
    private let store: GroupHandler
    private let context: CodeLaunchContext
    
    init(picker: Picker, context: CodeLaunchContext) {
        self.picker = picker
        self.context = context
        self.store = GroupHandler(picker: picker, context: context)
    }
}


// MARK: - Add
extension ProjectHandler {
    func addProject(path: String?, group: String?, shortcut: String?) throws {
        let path = try path ?? picker.getRequiredInput("Enter the path to your project.")
        let folder = try Folder(path: path)
        // TODO: - need to verify that project name is available
        let group = try store.getGroup(named: group)
        // TODO: - need to verify that project shortcut is available
        let shortcut = try shortcut ?? picker.getRequiredInput("Enter the shortcut to launch this project.")
        let projectType = try getProjectType(folder: folder)
        let remote = getRemote(folder: folder)
        let otherLinks = getOtherLinks()
        let project = LaunchProject(name: folder.name, shortcut: shortcut, type: projectType, remote: remote, links: otherLinks)
        
        try context.saveProject(project, in: group)
    }
}


// MARK: - Remove
extension ProjectHandler {
    func removeProject(name: String?, shortcut: String?) throws {
        let projects = try context.loadProjects()
        
        var projectToDelete: LaunchProject
        
        if let name, let project = projects.first(where: { $0.name.lowercased() == name.lowercased() }) {
            projectToDelete = project
        } else if let project = getProject(shortcut: shortcut, projects: projects) {
            projectToDelete = project
        } else {
            projectToDelete = try picker.requiredSingleSelection("Select a Project to remove", items: projects)
        }
        
        // TODO: - maybe indicate that this is different from evicting?
        try picker.requiredPermission("Are you sure want to remove \(projectToDelete.name.yellow)?")
        try context.deleteProject(projectToDelete)
    }
}


// MARK: - Private Methods
private extension ProjectHandler {
    func getProjectType(folder: Folder) throws -> ProjectType {
        return .package // TODO: -
    }
    
    func getRemote(folder: Folder) -> ProjectLink? {
        return nil // TODO: -
    }
    
    func getOtherLinks() -> [ProjectLink] {
        return [] // TODO: -
    }
    
    func getProject(shortcut: String?, projects: [LaunchProject]) -> LaunchProject? {
        guard let shortcut else {
            return nil
        }
        
        return projects.first { project in
            guard let projectShortcut = project.shortcut else {
                return false
            }
            
            return projectShortcut.lowercased() == shortcut.lowercased()
        }
    }
}
