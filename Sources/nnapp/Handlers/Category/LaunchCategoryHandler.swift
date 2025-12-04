//
//  LaunchCategoryHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import Files
import CodeLaunchKit
import SwiftPickerKit

struct LaunchCategoryHandler {
    private let store: any CategoryStore
    private let picker: any CommandLinePicker
    private let folderBrowser: any FolderBrowser
    
    init(store: any CategoryStore, picker: any CommandLinePicker, folderBrowser: any FolderBrowser) {
        self.store = store
        self.picker = picker
        self.folderBrowser = folderBrowser
    }
}


// MARK: - Add
extension LaunchCategoryHandler {
    func importCategory(path: String?) throws -> LaunchCategory {
        let categories = try loadAllCategories()
        let folder = try selectFolder(path: path, browsePrompt: "Select a folder to import as a Category")
        let name = try validateName(folder.name, categories: categories)
        
        return try saveCategory(.new(name: name, path: folder.path))
    }
    
    func createNewCategory(named name: String?, parentPath: String?) throws -> LaunchCategory {
        let categories = try loadAllCategories()
        let proposedName = try name ?? picker.getRequiredInput("Enter the name of your new category.")
        let name = try validateName(proposedName, categories: categories)
        let parentFolder = try selectParentFolder(path: parentPath, categoryName: name)
        let categoryFolder = try createSubfolder(named: name, in: parentFolder)
        
        return try saveCategory(.new(name: name, path: categoryFolder.path))
    }
}


// MARK: - Remove
extension LaunchCategoryHandler {
    func removeCategory(named name: String?) throws {
        let categories = try loadAllCategories()
        let categoryToDelete: LaunchCategory
        
        if let name, let category = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            categoryToDelete = category
        } else {
            categoryToDelete = try picker.requiredSingleSelection(
                "Select a category to remove",
                items: categories,
                layout: .twoColumnDynamic { makeCategoryDetail(for: $0) }
            )
        }
        
        try picker.requiredPermission("Are you sure want to remove \(categoryToDelete.name.yellow)?")
        try store.deleteCategory(categoryToDelete)
    }
}


// MARK: - Private Methods
private extension LaunchCategoryHandler {
    func loadAllCategories() throws -> [LaunchCategory] {
        return try store.loadCategories()
    }
    
    func selectFolder(path: String?, browsePrompt: String) throws -> Folder {
        return try folderBrowser.browseForFolder(prompt: browsePrompt, startPath: path)
    }
    
    func validateName(_ name: String, categories: [LaunchCategory]) throws -> String {
        if categories.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.categoryNameTaken
        }
        
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func selectParentFolder(path: String?, categoryName: String) throws -> Folder {
        let folder = try selectFolder(path: path, browsePrompt: "Select the folder where \(categoryName.yellow) should be created")
        
        try validateParentFolder(folder, categoryName: categoryName)
        
        return folder
    }
    
    func validateParentFolder(_ folder: Folder, categoryName: String) throws {
        if folder.subfolders.contains(where: { $0.name.matches(categoryName) }) {
            throw CodeLaunchError.categoryPathTaken
        }
    }
    
    func createSubfolder(named name: String, in parentFolder: Folder) throws -> Folder {
        return try parentFolder.createSubfolderIfNeeded(withName: name)
    }
    
    func saveCategory(_ category: LaunchCategory) throws -> LaunchCategory {
        try store.saveCategory(category)
        return category
    }
    
    func makeCategoryDetail(for category: LaunchCategory) -> String {
        let groupCount = category.groups.count
        let totalProjects = category.groups.reduce(0) { $0 + $1.projects.count }

        return """
        group count: \(groupCount)
        total project count: \(totalProjects)
        local path: \(category.path.yellow)
        """
    }
}

// MARK: - Dependencies
protocol CategoryStore {
    func loadCategories() throws -> [LaunchCategory]
    func saveCategory(_ category: LaunchCategory) throws
    func deleteCategory(_ category: LaunchCategory) throws
}
