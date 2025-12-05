//
//  LaunchCategoryHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct LaunchCategoryHandler {
    private let store: any CategoryStore
    private let picker: any LaunchPicker
    private let folderBrowser: any FolderBrowser
    
    init(store: any CategoryStore, picker: any LaunchPicker, folderBrowser: any FolderBrowser) {
        self.store = store
        self.picker = picker
        self.folderBrowser = folderBrowser
    }
}


// MARK: - Add
extension LaunchCategoryHandler {
    @discardableResult
    func importCategory(path: String?) throws -> LaunchCategory {
        let categories = try loadAllCategories()
        let folder = try selectFolder(path: path, browsePrompt: "Select a folder to import as a Category")
        let name = try validateName(folder.name, categories: categories)
        
        return try saveCategory(.new(name: name, path: folder.path))
    }
    
    @discardableResult
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


// MARK: - LaunchGroupCategorySelector
extension LaunchCategoryHandler: LaunchGroupCategorySelector {
    func getCategory(group: LaunchGroup) -> LaunchCategory? {
        guard let categories = try? loadAllCategories() else {
            return nil
        }
        
        return categories.first(where: { category in
            category.groups.contains(where: { $0.name.matches(group.name) })
        })
    }
    func selectCategory(named name: String?) throws -> LaunchCategory {
        let categories = try loadAllCategories()
        
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
private extension LaunchCategoryHandler {
    func loadAllCategories() throws -> [LaunchCategory] {
        return try store.loadCategories()
    }
    
    func selectFolder(path: String?, browsePrompt: String) throws -> Directory {
        return try folderBrowser.browseForFolder(prompt: browsePrompt, startPath: path)
    }
    
    func selectAssignCategoryType() throws -> AssignCategoryType {
        return try picker.requiredSingleSelection("How would you like to assign a Category to your Group?", items: AssignCategoryType.allCases, showSelectedItemText: false)
    }
    
    func validateName(_ name: String, categories: [LaunchCategory]) throws -> String {
        if categories.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.categoryNameTaken
        }
        
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func selectParentFolder(path: String?, categoryName: String) throws -> Directory {
        let folder = try selectFolder(path: path, browsePrompt: "Select the folder where \(categoryName.yellow) should be created")
        
        try validateParentFolder(folder, categoryName: categoryName)
        
        return folder
    }
    
    func validateParentFolder(_ folder: Directory, categoryName: String) throws {
        if folder.subdirectories.contains(where: { $0.name.matches(categoryName) }) {
            throw CodeLaunchError.categoryPathTaken
        }
    }
    
    func createSubfolder(named name: String, in parentFolder: Directory) throws -> Directory {
        return try parentFolder.createSubdirectory(named: name)
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
