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
