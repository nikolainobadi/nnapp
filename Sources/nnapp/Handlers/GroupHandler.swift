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


// MARK: -
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
