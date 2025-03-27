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
        let path = try path ?? picker.getRequiredInput("Enter the path to the folder you want to use.")
        
        // TODO: - need to verify that group name is available
        let folder = try Folder(path: path)
        let category = try store.getCategory(named: category)
        let group = LaunchGroup(name: folder.name)
        
        try context.saveGroup(group, in: category)
        
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
        
        switch try picker.requiredSingleSelection("How would you like to assign a Group to your Project?", items: AssignCategoryType.allCases) {
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
