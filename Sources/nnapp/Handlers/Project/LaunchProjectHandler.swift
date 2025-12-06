//
//  LaunchProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct LaunchProjectHandler {
    private let shell: any LaunchShell
    private let picker: any LaunchPicker
    private let fileSystem: any FileSystem
    private let store: any LaunchProjectStore
    private let folderBrowser: any DirectoryBrowser
    private let groupSelector: any LaunchProjectGroupSelector
    
    init(
        shell: any LaunchShell,
        store: any LaunchProjectStore,
        picker: any LaunchPicker,
        fileSystem: any FileSystem,
        folderBrowser: any DirectoryBrowser,
        groupSelector: any LaunchProjectGroupSelector
    ) {
        self.shell = shell
        self.store = store
        self.picker = picker
        self.fileSystem = fileSystem
        self.folderBrowser = folderBrowser
        self.groupSelector = groupSelector
    }
}


// MARK: - Add
extension LaunchProjectHandler {
    func addProject(path: String?, shortcut: String?, groupName: String?, isMainProject: Bool, fromDesktop: Bool) throws {
        let group = try selectGroup(named: groupName)
        let projectFolder = try selectProjectFolder(path: path, group: group, fromDesktop: fromDesktop)
        let info = try selectProjectInfo(folder: projectFolder.folder, shortcut: shortcut, group: group, isMainProject: isMainProject)
        let project = LaunchProject(info: info, type: projectFolder.type)
        
        try moveFolderIfNecessary(projectFolder.folder, parentPath: group.path)
        try saveProject(project, in: group)
    }
}


// MARK: - Remove
extension LaunchProjectHandler {
    func removeProject(name: String?, shortcut: String?) throws {
        let projectToDelete = try getProjectToDelete(name: name, shortcut: shortcut)
        
        // TODO: - maybe indicate that this is different from evicting?
        try picker.requiredPermission("Are you sure want to remove \(projectToDelete.name.yellow)?")
        try deleteProject(projectToDelete)
    }
}


// MARK: - Evict (placeholder)
extension LaunchProjectHandler {
    func evictProject(name: String?, shortcut: String?) throws {
        // TODO: - implement eviction flow (trash folder but keep registration)
        throw CodeLaunchError.invalidInput
    }
}


// MARK: - Private Methods
private extension LaunchProjectHandler {
    func selectGroup(named name: String?) throws -> LaunchGroup {
        return try groupSelector.selectGroup(name: name)
    }
    
    func selectProjectFolder(path: String?, group: LaunchGroup, fromDesktop: Bool) throws -> LaunchProjectFolder {
        let folderSelector = LaunchProjectFolderSelector(picker: picker, fileSystem: fileSystem, folderBrowser: folderBrowser)
        
        return try folderSelector.selectProjectFolder(path: path, group: group, fromDesktop: fromDesktop)
    }
    
    func selectProjectInfo(folder: Directory, shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> LaunchProjectInfo {
        let infoSelector = ProjectInfoSelector(shell: shell, picker: picker, infoLoader: store)
        
        return try infoSelector.selectProjectInfo(folder: folder, shortcut: shortcut, group: group, isMainProject: isMainProject)
    }
    
    func getProjectToDelete(name: String?, shortcut: String?) throws -> LaunchProject {
        let projects = try store.loadProjects()
        let prompt = "Select the Project you would like to remove."
        // TODO: - update when evict is enabled
//        let prompt = "Select the Project you would like to remove. (Note: this will unregister the project from quick-launch. If you want to remove the project and keep it available for quick launch, use \("evict".bold)"
        
        if let name {
            if let project = projects.first(where: { $0.name.lowercased().contains(name.lowercased()) }) {
                return project
            }
            
            print("Cannot find project named \(name)")
        } else if let shortcut {
            if let project = projects.first(where: { shortcut.matches($0.shortcut) }) {
                return project
            }
        }
        
        return try picker.requiredSingleSelection(prompt, items: projects, showSelectedItemText: false)
    }
    
    func moveFolderIfNecessary(_ folder: Directory, parentPath: String?) throws {
        guard let parentPath else {
            throw CodeLaunchError.missingGroup
        }
        
        let parentFolder = try fileSystem.directory(at: parentPath)
        
        if let existingSubfolder = try? parentFolder.subdirectory(named: folder.name) {
            if existingSubfolder.path != folder.path  {
                throw CodeLaunchError.folderNameTaken
            }
            
            print("Folder is already in correct location")
            return
        }
        
        try folder.move(to: parentFolder)
    }
    
    func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
        // TODO: - apply project shortcut to group if necessary
        try store.saveProject(project, in: group)
    }
    
    func deleteProject(_ project: LaunchProject) throws {
        try store.deleteProject(project, from: nil) // TODO: -
    }
}


// MARK: - Extension Dependencies
private extension LaunchProject {
    init(info: LaunchProjectInfo, type: ProjectType) {
        self.init(name: info.name, shortcut: info.shortcut, type: type, remote: info.remote, links: info.otherLinks)
    }
}
