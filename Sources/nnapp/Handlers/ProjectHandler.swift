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
    func addProject(path: String?, group: String?, shortcut: String?, isMainProject: Bool) throws {
        let selectedGroup = try store.getGroup(named: group)
        let projectFolder = try selectProjectFolder(path: path, group: selectedGroup)
        
        // TODO: - need to verify that project shortcut is available
        let shortcut = try shortcut ?? picker.getRequiredInput("Enter the shortcut to launch this project.")
        let remote = getRemote(folder: projectFolder.folder)
        let otherLinks = getOtherLinks()
        let project = LaunchProject(name: projectFolder.name, shortcut: shortcut, type: projectFolder.type, remote: remote, links: otherLinks)
        
        if isMainProject || (selectedGroup.shortcut == nil && picker.getPermission("Is this the main project of \(selectedGroup.name)?")) {
            selectedGroup.shortcut = shortcut
        }
        
        try context.saveProject(project, in: selectedGroup)
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
    // TODO: - need to verify that project name is available
    func selectProjectFolder(path: String?, group: LaunchGroup) throws -> ProjectFolder {
        if let path, let folder = try? Folder(path: path) {
            let projectType = try getProjectType(folder: folder)
            
            return .init(folder: folder, type: projectType)
        }
        
        guard let groupPath = group.path else {
            fatalError() // TODO: -
        }
        
        let groupFolder = try Folder(path: groupPath)
        let availableFolders = getAvailableSubfolders(group: group, folder: groupFolder)
        
        if !availableFolders.isEmpty, picker.getPermission("Would you like to select a project from the \(groupFolder.name) folder?") {
            return try picker.requiredSingleSelection("Select a folder", items: availableFolders)
        }
        
        let path = try picker.getRequiredInput("Enter the path to the folder you want to use.")
        let folder = try Folder(path: path)
        let projectType = try getProjectType(folder: folder)
        
        return .init(folder: folder, type: projectType)
    }
    
    func getAvailableSubfolders(group: LaunchGroup, folder: Folder) -> [ProjectFolder] {
        return folder.subfolders.compactMap { subFolder in
            guard !group.projects.map({ $0.name.lowercased() }).contains(subFolder.name.lowercased()), let projectType = try? getProjectType(folder: subFolder) else {
                return nil
            }
            
            return .init(folder: subFolder, type: projectType)
        }
    }
    
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


// MARK: - Dependencies
struct ProjectFolder {
    let folder: Folder
    let type: ProjectType
    
    var name: String {
        return folder.name
    }
}
