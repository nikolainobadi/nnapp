//
//  CategoryHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import Files
import SwiftPicker

struct CategoryHandler {
    private let picker: Picker
    private let context: CodeLaunchContext
    
    init(picker: Picker, context: CodeLaunchContext) {
        self.picker = picker
        self.context = context
    }
}


// MARK: -
extension CategoryHandler {
    @discardableResult
    func importCategory(path: String?) throws -> LaunchCategory {
        let path = try path ?? picker.getRequiredInput("Enter the path to the folder you want to use.")
        let folder = try Folder(path: path)
        
        // TODO: - need to verify that category name is available
        let category = LaunchCategory(name: folder.name, path: folder.path)
        
        try context.saveCatgory(category)
        
        return category
    }
    
    @discardableResult
    func createCategory(name: String?, parentPath: String?) throws -> LaunchCategory {
        // TODO: - need to verify that name is available
        let name = try name ?? picker.getRequiredInput("Enter the name of your new category.")
        let path = try parentPath ?? picker.getRequiredInput("Enter the path to the folder where \(name.yellow) should be created.")
        let parentFolder = try Folder(path: path)
        let category = LaunchCategory(name: name, path: path)
        
        // TODO: - maybe verify that another folder doesn't already have that name in parentFolder?
        try parentFolder.createSubfolder(named: name)
        try context.saveCatgory(category)
        
        return category
    }
}


// MARK: -
extension CategoryHandler {
    func getCategory(named name: String?) throws -> LaunchCategory {
        let categories = try context.loadCategories()
        
        if let name {
            if let category = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
                return category
            }
            
            try picker.requiredPermission("Could not find a category named \(name.yellow). Would you like to add it?")
        }
        
        switch try picker.requiredSingleSelection("How would you like to assign a category to your group?", items: AssignCategoryType.allCases) {
        case .select:
            return try picker.requiredSingleSelection("Select a Category", items: categories)
        case .create:
            return try createCategory(name: name, parentPath: nil)
        case .import:
            return try importCategory(path: nil)
        }
    }
}


// MARK: - Dependencies
enum AssignCategoryType: CaseIterable {
    case select, create, `import`
}

extension AssignCategoryType: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .select:
            return "Select an existing Category"
        case .create:
            return "Create new Category and folder"
        case .import:
            return "Import existing folder to create new Category"
        }
    }
}
