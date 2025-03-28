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
    private let store: CategoryHandler
    private let context: CodeLaunchContext
    
    init(picker: Picker, context: CodeLaunchContext) {
        self.picker = picker
        self.context = context
        self.store = CategoryHandler(picker: picker, context: context)
    }
}


// MARK: - Add
extension GroupHandler {
    @discardableResult
    func importGroup(path: String?, category: String?) throws -> LaunchGroup {
        let selectedCategory = try store.getCategory(named: category)
        // TODO: - maybe verify that another group doesn't already exist with that name?
        let selectedGroupFolder = try selectGroupFolderToImport(path: path, category: selectedCategory)
        let group = LaunchGroup(name: selectedGroupFolder.name)
        
        try context.saveGroup(group, in: selectedCategory)
        
        return group
    }
    
    @discardableResult
    func createGroup(name: String?, category: String?) throws -> LaunchGroup {
        let name = try name ?? picker.getRequiredInput("Enter the name of your new group.")
        let category = try store.getCategory(named: category)
        let categoryFolder = try Folder(path: category.path)
        let group = LaunchGroup(name: name)
        
        // TODO: - maybe verify that another folder doesn't already have that name in categoryFolder?
        try categoryFolder.createSubfolder(named: name)
        try context.saveGroup(group, in: category)
        
        return group
    }
}


// MARK: -
extension GroupHandler {
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
enum AssignGroupType: CaseIterable {
    case select, create, `import`
}

extension AssignGroupType: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .select:
            return "Select an existing Group"
        case .create:
            return "Create new Group and folder"
        case .import:
            return "Import existing folder to create new Group"
        }
    }
}
