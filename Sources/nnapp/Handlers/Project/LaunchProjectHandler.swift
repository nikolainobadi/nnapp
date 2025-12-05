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
    private let store: any LaunchProjectStore
    private let picker: any CommandLinePicker
    private let folderBrowser: any FolderBrowser
    private let groupSelector: any LaunchProjectGroupSelector
}


// MARK: - Add
extension LaunchProjectHandler {
    func addProject(path: String?, shortcut: String?, groupName: String?, isMainProject: Bool, fromDesktop: Bool) throws {
        let group = try selectGroup(named: groupName)
        let groupPath = getPath(for: group)
        let projectFolder = try selectProjectFolder(path: path, group: group, fromDesktop: fromDesktop)
        let info = try selectProjectInfo(folder: projectFolder.folder, shortcut: shortcut, group: group, isMainProject: isMainProject)
        let project = LaunchProject(info: info, type: projectFolder.type)
        
        try moveFolderIfNecessary(projectFolder.folder, parentPath: groupPath)
        try saveProject(project, in: group)
    }
}


// MARK: - Remove
extension LaunchProjectHandler {
    func removeProject(name: String?, shortcut: String?) throws {
        let projectToDelete = try getProject(name: name, shortcut: shortcut)
        
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
        fatalError() // TODO: -
    }
    
    func selectProjectInfo(folder: Folder, shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> LaunchProjectInfo {
        fatalError() // TODO: -
    }
    
    func getPath(for group: LaunchGroup) -> String? {
        return nil // TODO: -
    }
    
    func getProject(name: String?, shortcut: String?) throws -> LaunchProject {
        fatalError() // TODO: -
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


// MARK: - Dependencies
protocol LaunchProjectGroupSelector {
    func selectGroup(name: String?) throws -> LaunchGroup
}

protocol LaunchProjectStore {
    func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws
    func deleteProject(_ project: LaunchProject, from group: LaunchGroup?) throws
}

struct LaunchProjectInfo {
    let name: String
    let shortcut: String?
    let remote: ProjectLink?
    let otherLinks: [ProjectLink]
}

struct LaunchProjectFolder {
    let folder: Folder
    let type: ProjectType

    /// The name of the folder, used as the project name.
    var name: String {
        return folder.name
    }
}

// MARK: - Extension Dependencies
private extension LaunchProject {
    init(info: LaunchProjectInfo, type: ProjectType) {
        self.init(name: info.name, shortcut: info.shortcut, type: type, remote: info.remote, links: info.otherLinks)
    }
}
