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
            abstract: "Create a new folder for a Category or Group and register it in the database.",
            subcommands: [Category.self, Group.self]
        )
    }
}


// MARK: - Category
extension Nnapp.Create {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Create a new Category folder and register it in the database."
        )
        
        @Argument(help: "The name of your new Category")
        var name: String?
        
        @Option(name: .shortAndLong, help: "The path to the parent folder where your new Category folder should be created.")
        var parentPath: String?
        
        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let handler = CategoryHandler(picker: picker, context: context)
            
            try handler.createCategory(name: name, parentPath: parentPath)
        }
    }
}


// MARK: - Group
extension Nnapp.Create {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Create a new Group folder and register it in the database."
        )
        
        @Argument(help: "The name of your new Group")
        var name: String?
        
        @Option(name: .shortAndLong, help: "The name of the Category to assign to the new Group.")
        var category: String?
        
        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let handler = GroupHandler(picker: picker, context: context)
            
            try handler.createGroup(name: name, category: category)
        }
    }
}
