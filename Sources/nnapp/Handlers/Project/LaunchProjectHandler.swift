//
//  LaunchProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import Files
import NnShellKit
import CodeLaunchKit
import SwiftPickerKit

struct LaunchProjectHandler {
    private let shell: any Shell
    private let desktopPath: String?
    private let store: any LaunchProjectStore
    private let picker: any CommandLinePicker
    private let folderBrowser: any FolderBrowser
    private let groupSelector: any LaunchProjectGroupSelector
    
    init(
        shell: any Shell,
        desktopPath: String?,
        store: any LaunchProjectStore,
        picker: any CommandLinePicker,
        folderBrowser: any FolderBrowser,
        groupSelector: any LaunchProjectGroupSelector
    ) {
        self.shell = shell
        self.desktopPath = desktopPath
        self.store = store
        self.picker = picker
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


// MARK: - Private Methods
private extension LaunchProjectHandler {
    func selectGroup(named name: String?) throws -> LaunchGroup {
        return try groupSelector.selectGroup(name: name)
    }
    
    func selectProjectFolder(path: String?, group: LaunchGroup, fromDesktop: Bool) throws -> LaunchProjectFolder {
        let folderSelector = LaunchProjectFolderSelector(picker: picker, folderBrowser: folderBrowser, desktopPath: desktopPath)
        
        return try folderSelector.selectProjectFolder(path: path, group: group, fromDesktop: fromDesktop)
    }
    
    func selectProjectInfo(folder: Folder, shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> LaunchProjectInfo {
        let gitshell = GitShellAdapter(shell: shell)
        let infoSelector = LaunchProjectInfoSelector(picker: picker, gitShell: gitshell, infoLoader: store)
        
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
    
    func moveFolderIfNecessary(_ folder: Folder, parentPath: String?) throws {
        guard let parentPath else {
            throw CodeLaunchError.missingGroup
        }
        
        let parentFolder = try Folder(path: parentPath)
        
        if let existingSubfolder = try? parentFolder.subfolder(named: folder.name) {
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
        self.init(name: info.name, shortcut: info.shortcut, type: type, remote: info.remote, links: info.otherLinks, group: nil)
    }
}
