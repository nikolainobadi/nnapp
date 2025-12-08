//
//  CategoryController.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct CategoryController {
    private let picker: any LaunchPicker
    private let manager: any CategoryService
    private let fileSystem: any FileSystem
    private let folderBrowser: any DirectoryBrowser
    
    init(manager: any CategoryService, picker: any LaunchPicker, fileSystem: any FileSystem, folderBrowser: any DirectoryBrowser) {
        self.picker = picker
        self.manager = manager
        self.fileSystem = fileSystem
        self.folderBrowser = folderBrowser
    }
}


// MARK: - Add
extension CategoryController {
    @discardableResult
    func importCategory(path: String?) throws -> LaunchCategory {
        let folder = try selectFolder(path: path, browsePrompt: "Select a folder to import as a Category")
        
        return try manager.importCategory(from: folder)
    }
    
    @discardableResult
    func createNewCategory(named name: String?, parentPath: String?) throws -> LaunchCategory {
        let proposedName = try name ?? picker.getRequiredInput("Enter the name of your new category.")
        let parentFolder = try selectFolder(path: parentPath, browsePrompt: "Select the folder where \(proposedName.yellow) should be created")
        
        return try manager.createCategory(named: proposedName, in: parentFolder)
    }
}


// MARK: - Remove
extension CategoryController {
    func removeCategory(named name: String?) throws {
        let categories = try manager.loadCategories()
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
        try manager.deleteCategory(categoryToDelete)
    }
}


// MARK: - LaunchGroupCategorySelector
extension CategoryController: LaunchGroupCategorySelector {
    func getCategory(group: LaunchGroup) -> LaunchCategory? {
        return manager.category(for: group)
    }
    
    func selectCategory(named name: String?) throws -> LaunchCategory {
        let categories = try manager.loadCategories()
        
        if let name {
            if let category = categories.first(where: { $0.name.matches(name) }) {
                return category
            }
            
            try picker.requiredPermission("Could not find a category named \(name.yellow). Would you like to add it?")
        }
        
        switch try selectAssignCategoryType() {
        case .import:
            return try importCategory(path: nil)
        case .create:
            return try createNewCategory(named: name, parentPath: nil)
        case .select:
            return try picker.requiredSingleSelection("Select a Category", items: categories, showSelectedItemText: false)
        }
    }
}


// MARK: - Private Methods
private extension CategoryController {
    func selectFolder(path: String?, browsePrompt: String) throws -> Directory {
        if let path {
            return try fileSystem.directory(at: path)
        }
        
        return try folderBrowser.browseForDirectory(prompt: browsePrompt)
    }
    
    func selectAssignCategoryType() throws -> AssignCategoryType {
        return try picker.requiredSingleSelection("How would you like to assign a Category to your Group?", items: AssignCategoryType.allCases, showSelectedItemText: false)
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
