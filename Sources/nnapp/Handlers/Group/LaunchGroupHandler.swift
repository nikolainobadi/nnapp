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
    private let picker: any CommandLinePicker
    private let categorySelector: any LaunchGroupCategorySelector
    
    init(picker: any CommandLinePicker, categorySelector: any LaunchGroupCategorySelector) {
        self.picker = picker
        self.categorySelector = categorySelector
    }
}


// MARK: - Add
extension LaunchGroupHandler {
    func importGroup(path: String?, categoryName: String?) throws -> LaunchGroup {
        let category = try selectCategory(name: categoryName)
        let groupFolder = try selectGroupFolder(path: path, category: category)
        let group = LaunchGroup.new(name: groupFolder.name)
        
        // validate name
        // move group folder to category folder if necessary
        
        try saveGroup(group)
        
        return group
    }
    
    func createNewGroup(named name: String?, categoryName: String?) throws -> LaunchGroup {
        let category = try selectCategory(name: categoryName)
        let name = try name ?? picker.getRequiredInput("Enter the name of your new group.")
        let group = LaunchGroup.new(name: name)
        
        // validate name
        // create group folder in category folder
        print("create group folder in \(category.name) folder")
        
        try saveGroup(group)
        
        return group
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
//        try store.deleteGroup(groupToDelete)
    }
}


// MARK: - Private Methods
private extension LaunchGroupHandler {
    func selectCategory(name: String?) throws -> LaunchCategory {
        fatalError() // TODO: -
    }
    
    func selectGroupFolder(path: String?, category: LaunchCategory) throws -> Folder {
        fatalError() // TODO: -
    }
    
    func loadAllGroups() throws -> [LaunchGroup] {
        return [] // TODO: -
    }
    
    func saveGroup(_ group: LaunchGroup) throws {
        // TODO: -
    }
    
    func makeGroupDetail(for group: LaunchGroup) -> String {
        fatalError() // TODO: - 
//        let categoryName = group.category?.name ?? "Not assigned"
//        let path = group.path?.yellow ?? "path not set"
//        let shortcut = group.shortcut ?? "None"
//
//        return """
//        project count: \(group.projects.count)
//        shortcut: \(shortcut)
//        category: \(categoryName)
//        path: \(path)
//        """
    }
}


// MARK: - Dependencies
protocol LaunchGroupCategorySelector {
    func getCategory(named name: String?) throws -> LaunchCategory
}
