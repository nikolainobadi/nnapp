//
//  GroupHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import Files
import SwiftPicker

struct GroupHandler {
    private let picker: Picker
    private let context: CodeLaunchContext
    private let categorySelector: GroupCategorySelector
    
    init(picker: Picker, context: CodeLaunchContext, categorySelector: GroupCategorySelector) {
        self.picker = picker
        self.context = context
        self.categorySelector = categorySelector
    }
}


// MARK: - Add
extension GroupHandler {
    @discardableResult
    func importGroup(path: String?, category: String?) throws -> LaunchGroup {
        let selectedCategory = try categorySelector.getCategory(named: category)
        let selectedGroupFolder = try selectGroupFolderToImport(path: path, category: selectedCategory)
        let group = LaunchGroup(name: selectedGroupFolder.name)
        
        try validateName(group.name, groups: selectedCategory.groups)
        try moveFolderIfNecessary(selectedGroupFolder, category: selectedCategory)
        try context.saveGroup(group, in: selectedCategory)
        
        return group
    }
    
    @discardableResult
    func createGroup(name: String?, category: String?) throws -> LaunchGroup {
        let category = try categorySelector.getCategory(named: category)
        let name = try name ?? picker.getRequiredInput("Enter the name of your new group.")
        try validateName(name, groups: category.groups)
        let group = LaunchGroup(name: name)
        try createNewGroupFolder(group: group, category: category)
        try context.saveGroup(group, in: category)
        
        return group
    }
}


// MARK: - Helper
extension GroupHandler: ProjectGroupSelector {
    func getGroup(named name: String?) throws -> LaunchGroup {
        let groups = try context.loadGroups()
        
        if let name {
            if let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
                return group
            }
            
            try picker.requiredPermission("Could not find a group named \(name.yellow). Would you like to add it?")
        }
        
        switch try picker.requiredSingleSelection("How would you like to assign a Group to your Project?", items: AssignGroupType.allCases) {
        case .select:
            return try picker.requiredSingleSelection("Select a Group", items: groups)
        case .create:
            return try createGroup(name: name, category: nil)
        case .import:
            return try importGroup(path: nil, category: nil)
        }
    }
}


// MARK: - Remove
extension GroupHandler {
    func removeGroup(name: String?) throws {
        let groups = try context.loadGroups()
        
        var groupToDelete: LaunchGroup
        
        if let name, let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
            groupToDelete = group
        } else {
            groupToDelete = try picker.requiredSingleSelection("Select a group to delete", items: groups)
        }
        
        // TODO: - maybe display project count
        try picker.requiredPermission("Are you sure want to remove \(groupToDelete.name.yellow)?")
        
        try context.deleteGroup(groupToDelete)
    }
}


// MARK: - Private Methods
private extension GroupHandler {
    func validateName(_ name: String, groups: [LaunchGroup]) throws {
        if groups.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.groupNameTaken
        }
    }
    
    func createNewGroupFolder(group: LaunchGroup, category: LaunchCategory) throws {
        let categoryFolder = try Folder(path: category.path)
        let subfolderNames = categoryFolder.subfolders.map({ $0.name })
        
        if subfolderNames.contains(where: { $0.matches(group.name) }) {
            throw CodeLaunchError.groupFolderAlreadyExists
        }
        
        try categoryFolder.createSubfolder(named: group.name)
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
    
    func selectGroupFolderToImport(path: String?, category: LaunchCategory) throws -> Folder {
        if let path {
            return try Folder(path: path)
        }
        
        let categoryFolder = try Folder(path: category.path)
        let availableFolders = categoryFolder.subfolders.filter { folder in
            return !category.groups.map({ $0.name.lowercased() }).contains(folder.name.lowercased())
        }
        
        if !availableFolders.isEmpty, picker.getPermission("Would you like to select a subfolder of \(categoryFolder.name)?") {
            return try picker.requiredSingleSelection("Select a folder", items: availableFolders)
        }
        
        let path = try picker.getRequiredInput("Enter the path to your folder for your new Group.")
        
        return try Folder(path: path)
    }
}


// MARK: - Dependencies
protocol GroupCategorySelector {
    func getCategory(named name: String?) throws -> LaunchCategory
}
