//
//  ProjectFolderSelector.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Files
import SwiftPicker

struct ProjectFolderSelector {
    private let picker: Picker
    
    init(picker: Picker) {
        self.picker = picker
    }
}


// MARK: - Action
extension ProjectFolderSelector {
    func selectProjectFolder(path: String?, group: LaunchGroup) throws -> ProjectFolder {
        if let path, let folder = try? Folder(path: path) {
            let projectType = try getProjectType(folder: folder)
            
            return .init(folder: folder, type: projectType)
        }
        
        guard let groupPath = group.path else {
            print("unable to resolve local path for \(group.name)")
            throw CodeLaunchError.missingGroup
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
}


// MARK: - Private Methods
private extension ProjectFolderSelector {
    func getProjectType(folder: Folder) throws -> ProjectType {
        if folder.containsFile(named: "Package.swift") {
            return .package
        }
        
        if folder.subfolders.contains(where: { $0.extension == "xcodeproj" }) {
            return .project
        }
        
        // TODO: - will need to also check for a workspace, then ask the user to choose which to use
        throw CodeLaunchError.noProjectInFolder
    }
    
    func getAvailableSubfolders(group: LaunchGroup, folder: Folder) -> [ProjectFolder] {
        return folder.subfolders.compactMap { subFolder in
            guard !group.projects.map({ $0.name.lowercased() }).contains(subFolder.name.lowercased()), let projectType = try? getProjectType(folder: subFolder) else {
                return nil
            }
            
            return .init(folder: subFolder, type: projectType)
        }
    }
}
