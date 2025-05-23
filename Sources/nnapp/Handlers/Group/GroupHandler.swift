//
//  GroupHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import Files
import SwiftPicker

/// Handles creation, import, selection, and deletion of `LaunchGroup` objects.
/// Groups belong to a `LaunchCategory` and contain one or more `LaunchProject` entries.
struct GroupHandler {
    private let picker: Picker
    private let context: CodeLaunchContext
    private let categorySelector: GroupCategorySelector

    /// Initializes a new handler for managing groups within a selected category.
    /// - Parameters:
    ///   - picker: Utility for prompting user input.
    ///   - context: Data context for persistence and fetching.
    ///   - categorySelector: Used to determine the group’s parent category.
    init(picker: Picker, context: CodeLaunchContext, categorySelector: GroupCategorySelector) {
        self.picker = picker
        self.context = context
        self.categorySelector = categorySelector
    }
}


// MARK: - Add
extension GroupHandler {
    /// Imports a group from an existing folder and registers it under a category.
    /// - Parameters:
    ///   - path: Optional absolute folder path to import.
    ///   - category: Optional name of the category to assign the group to.
    /// - Returns: The newly imported `LaunchGroup`.
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

    /// Creates a new group by prompting for a name and folder location.
    /// - Parameters:
    ///   - name: Optional group name.
    ///   - category: Optional name of the category to assign the group to.
    /// - Returns: The newly created `LaunchGroup`.
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
    /// Selects or creates a group to assign a project to.
    /// - Parameter name: Optional group name to match.
    /// - Returns: The selected or newly created `LaunchGroup`.
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
    /// Removes a group from the database after user confirmation.
    /// - Parameter name: Optional name of the group to delete. If `nil`, user selects from list.
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
    /// Ensures the group name doesn't already exist under the given category.
    func validateName(_ name: String, groups: [LaunchGroup]) throws {
        if groups.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.groupNameTaken
        }
    }

    /// Creates a folder on disk for the group within its parent category.
    func createNewGroupFolder(group: LaunchGroup, category: LaunchCategory) throws {
        let categoryFolder = try Folder(path: category.path)
        let subfolderNames = categoryFolder.subfolders.map({ $0.name })

        if subfolderNames.contains(where: { $0.matches(group.name) }) {
            throw CodeLaunchError.groupFolderAlreadyExists
        }

        try categoryFolder.createSubfolder(named: group.name)
    }

    /// Moves a group folder into its assigned category folder if needed.
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

    /// Selects a folder to use for group import, optionally from disk or from subfolders.
    func selectGroupFolderToImport(path: String?, category: LaunchCategory) throws -> Folder {
        if let path {
            return try Folder(path: path)
        }

        let categoryFolder = try Folder(path: category.path)
        let availableFolders = categoryFolder.subfolders.filter { folder in
            !category.groups.map({ $0.name.lowercased() }).contains(folder.name.lowercased())
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
