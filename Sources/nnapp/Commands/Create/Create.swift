//
//  Create.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import ArgumentParser

extension Nnapp {
    struct Create: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "",
            subcommands: [Category.self, Group.self]
        )
    }
}


// MARK: - Category
extension Nnapp.Create {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "")
        var name: String?
        
        @Option(name: .shortAndLong, help: "")
        var parentPath: String?
        
        func run() throws {
            let context = try makeContext()
            let handler = CategoryHandler(picker: picker, context: context)
            
            try handler.createCategory(name: name, parentPath: parentPath)
        }
    }
}


// MARK: - Group
extension Nnapp.Create {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "")
        var name: String?
        
        @Option(name: .shortAndLong, help: "")
        var category: String?
        
        func run() throws {
            let context = try makeContext()
            // TODO: - need to verify that name is available
            let name = try name ?? picker.getRequiredInput("Enter the name of your new group.")
            let category = try getCategory(named: category, context: context)
            let categoryFolder = try Folder(path: category.path)
            let group = LaunchGroup(name: name)
            
            // TODO: - maybe verify that another folder doesn't already have that name in categoryFolder?
            try categoryFolder.createSubfolder(named: name)
            try context.saveGroup(group, in: category)
        }
    }
}

// TODO: - need to encapsulate to reduce code duplication
private extension Nnapp.Create.Group {
    func getCategory(named name: String?, context: CodeLaunchContext) throws -> LaunchCategory {
        // TODO: - for now only handle existing categories
        let name = try name ?? picker.getRequiredInput("Enter the name of the category for this new group.")
        let categories = try context.loadCategories()
        
        if let category = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return category
        }
        
        throw NnappError.missingCategory
    }
}
