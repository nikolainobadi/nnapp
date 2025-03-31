//
//  CategoryHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import Files
import SwiftPicker

/// Handles creation, import, selection, and deletion of `LaunchCategory` objects.
/// Used by commands to manage high-level category folders and associated model persistence.
struct CategoryHandler {
    private let picker: Picker
    private let context: CodeLaunchContext

    /// Initializes a new handler for managing categories.
    /// - Parameters:
    ///   - picker: User-facing selection and input utility.
    ///   - context: The persistence context for loading and saving models.
    init(picker: Picker, context: CodeLaunchContext) {
        self.picker = picker
        self.context = context
    }
}


// MARK: - Add
extension CategoryHandler {
    /// Imports a category from an existing folder on disk and registers it in the database.
    /// - Parameter path: Optional absolute path to the folder. If `nil`, prompts the user.
    /// - Returns: The imported `LaunchCategory`.
    @discardableResult
    func importCategory(path: String?) throws -> LaunchCategory {
        let categories = try context.loadCategories()
        let path = try path ?? picker.getRequiredInput("Enter the path to the folder you want to use.")
        let folder = try Folder(path: path)

        try validateName(folder.name, categories: categories)
        let category = LaunchCategory(name: folder.name, path: folder.path)

        try context.saveCategory(category)
        return category
    }

    /// Creates a new category by making a folder on disk and registering it in the database.
    /// - Parameters:
    ///   - name: Optional category name. If `nil`, prompts the user.
    ///   - parentPath: Optional path to the parent directory. If `nil`, prompts the user.
    /// - Returns: The newly created `LaunchCategory`.
    @discardableResult
    func createCategory(name: String?, parentPath: String?) throws -> LaunchCategory {
        let categories = try context.loadCategories()
        let name = try name ?? picker.getRequiredInput("Enter the name of your new category.")

        try validateName(name, categories: categories)

        let path = try parentPath ?? picker.getRequiredInput("Enter the path to the folder where \(name.yellow) should be created.")
        let parentFolder = try Folder(path: path)

        try validateParentFolder(parentFolder, categoryName: name)
        let categoryFolder = try parentFolder.createSubfolder(named: name)
        let category = LaunchCategory(name: name, path: categoryFolder.path)

        try context.saveCategory(category)
        return category
    }
}


// MARK: - Remove
extension CategoryHandler {
    /// Removes a category from the database after confirming with the user.
    /// - Parameter name: Optional name of the category to remove. If `nil`, user selects from list.
    func removeCategory(name: String?) throws {
        let categories = try context.loadCategories()
        var categoryToDelete: LaunchCategory

        if let name, let category = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            categoryToDelete = category
        } else {
            categoryToDelete = try picker.requiredSingleSelection("Select a category to remove", items: categories)
        }

        // TODO: - maybe display group count with project count
        try picker.requiredPermission("Are you sure want to remove \(categoryToDelete.name.yellow)?")
        try context.deleteCategory(categoryToDelete)
    }
}


// MARK: - Helper
extension CategoryHandler: GroupCategorySelector {
    /// Resolves a category to use for group creation, based on the provided name or user input.
    /// - Parameter name: Optional category name to look up.
    /// - Returns: A selected or newly created `LaunchCategory`.
    func getCategory(named name: String?) throws -> LaunchCategory {
        let categories = try context.loadCategories()

        if let name {
            if let category = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
                return category
            }
            try picker.requiredPermission("Could not find a category named \(name.yellow). Would you like to add it?")
        }

        switch try picker.requiredSingleSelection("How would you like to assign a Category to your Group?", items: AssignCategoryType.allCases) {
        case .select:
            return try picker.requiredSingleSelection("Select a Category", items: categories)
        case .create:
            return try createCategory(name: name, parentPath: nil)
        case .import:
            return try importCategory(path: nil)
        }
    }
}


// MARK: - Private Methods
private extension CategoryHandler {
    /// Ensures the provided name is unique among existing categories.
    func validateName(_ name: String, categories: [LaunchCategory]) throws {
        if categories.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.categoryNameTaken
        }
    }

    /// Ensures the parent folder does not already contain a subfolder with the given category name.
    func validateParentFolder(_ folder: Folder, categoryName: String) throws {
        if folder.subfolders.contains(where: { $0.name.matches(categoryName) }) {
            throw CodeLaunchError.categoryPathTaken
        }
    }
}
