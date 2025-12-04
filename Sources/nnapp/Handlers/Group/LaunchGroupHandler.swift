//
//  LaunchGroupHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import Files
import CodeLaunchKit
import SwiftPickerKit

struct LaunchGroupHandler {
    private let store: any LaunchGroupStore
    private let picker: any CommandLinePicker
    private let folderBrowser: any FolderBrowser
    private let categorySelector: any LaunchGroupCategorySelector
}


// MARK: - Add
extension LaunchGroupHandler {
    func importGroup(path: String?, categoryName: String?) throws -> LaunchGroup {
        let category = try selectCategory(name: categoryName)
        let groupFolder = try selectGroupFolder(path: path, category: category)
        let name = try validateName(groupFolder.name, groups: category.groups)
        
        return try saveGroup(.new(name: name), in: category)
    }
    
    func createNewGroup(named name: String?, categoryName: String?) throws -> LaunchGroup {
        let category = try selectCategory(name: categoryName)
        let proposedName = try name ?? picker.getRequiredInput("Enter the name of your new group.")
        let name = try validateName(proposedName, groups: category.groups)
    
        return try saveGroup(.new(name: name), in: category)
    }
}


// MARK: - Remove
extension LaunchGroupHandler {
    func removeGroup(named name: String?) throws {
        let groups = try loadAllGroups()
        let groupToDelete: LaunchGroup
        
        if let name, let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
            groupToDelete = group
        } else {
            groupToDelete = try picker.requiredSingleSelection(
                "Select a group to delete",
                items: groups,
                layout: .twoColumnDynamic { makeGroupDetail(for: $0) }
            )
        }
        
        try picker.requiredPermission("Are you sure want to remove \(groupToDelete.name.yellow)?")
        try deleteGroup(groupToDelete)
    }
}


// MARK: - LaunchProjectGroupSelector
extension LaunchGroupHandler: LaunchProjectGroupSelector {
    func selectGroup(name: String?) throws -> LaunchGroup {
        let groups = try loadAllGroups()
        
        if let name {
            if let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
                return group
            }
            try picker.requiredPermission("Could not find a group named \(name.yellow). Would you like to add it?")
        }

        switch try selectAssignGroupType() {
        case .import:
            return try importGroup(path: nil, categoryName: nil)
        case .create:
            return try createNewGroup(named: name, categoryName: nil)
        case .select:
            return try picker.requiredSingleSelection("Select a Group", items: groups, showSelectedItemText: false)
        }
    }
}


// MARK: - Private Methods
private extension LaunchGroupHandler {
    func selectCategory(name: String?) throws -> LaunchCategory {
        return try categorySelector.selectCategory(named: name)
    }
    
    func selectAssignGroupType() throws -> AssignGroupType {
        return try picker.requiredSingleSelection("How would you like to assign a Group to your Project?", items: AssignGroupType.allCases, showSelectedItemText: false)
    }
    
    func selectGroupFolder(path: String?, category: LaunchCategory) throws -> Folder {
        if let path {
            return try .init(path: path)
        }
        
        let categoryFolder = try Folder(path: category.path)
        let availableFolders = categoryFolder.subfolders.filter { folder in
            !category.groups.map({ $0.name.lowercased() }).contains(folder.name.lowercased())
        }

        if !availableFolders.isEmpty, picker.getPermission("Would you like to select a subfolder of \(categoryFolder.name)?") {
            return try picker.requiredSingleSelection("Select a folder", items: availableFolders, showSelectedItemText: false)
        }

        return try folderBrowser.browseForFolder(prompt: "Browse to select a folder to import as a Group")
    }
    
    func loadAllGroups() throws -> [LaunchGroup] {
        return try store.loadGroups()
    }
    
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory, groupFolder: Folder? = nil) throws -> LaunchGroup {
        if let groupFolder {
            try moveFolderIfNecessary(groupFolder, category: category)
        } else {
            try createNewGroupFolder(group: group, category: category)
        }
        
        try store.saveGroup(group, in: category)
        return group
    }
    
    func validateName(_ name: String, groups: [LaunchGroup]) throws -> String {
        if groups.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.groupNameTaken
        }
        
        return name
    }
    
    func moveFolderIfNecessary(_ folder: Folder, category: LaunchCategory) throws {
        let categoryFolder = try Folder(path: category.path)
        
        if let existingFolder = try? categoryFolder.subfolder(named: folder.name) {
            if existingFolder.path != folder.path {
                throw CodeLaunchError.groupFolderAlreadyExists
            }
            
            print("folder is already in the correct location")
            return
        }
        
        try folder.move(to: categoryFolder)
    }
    
    func createNewGroupFolder(group: LaunchGroup, category: LaunchCategory) throws {
        let categoryFolder = try Folder(path: category.path)
        let subfolderNames = categoryFolder.subfolders.map({ $0.name })

        if subfolderNames.contains(where: { $0.matches(group.name) }) {
            throw CodeLaunchError.groupFolderAlreadyExists
        }

        try categoryFolder.createSubfolder(named: group.name)
    }
    
    func deleteGroup(_ group: LaunchGroup) throws {
        let category = categorySelector.getCategory(group: group)
        
        try store.deleteGroup(group, from: category)
    }
    
    func makeGroupDetail(for group: LaunchGroup) -> String {
        let category = categorySelector.getCategory(group: group)
        let categoryName = category?.name ?? "Not assigned"
        let groupPath = category?.path.appendingPathComponent(group.name)
        let path = groupPath?.yellow ?? "path not set"
        let shortcut = group.shortcut ?? "None"

        return """
        project count: \(group.projects.count)
        shortcut: \(shortcut)
        category: \(categoryName)
        path: \(path)
        """
    }
}


// MARK: - Dependencies
protocol LaunchGroupCategorySelector {
    func getCategory(group: LaunchGroup) -> LaunchCategory?
    func selectCategory(named name: String?) throws -> LaunchCategory
}

protocol LaunchGroupStore {
    func loadGroups() throws -> [LaunchGroup]
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory) throws
    func deleteGroup(_ group: LaunchGroup, from category: LaunchCategory?) throws
}
