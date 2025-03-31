//
//  Create.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import ArgumentParser

/// Creates a new Category or Group folder and registers it in the database.
/// Use this command when you want to generate the folder instead of importing an existing one.
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
    /// Creates a new Category by generating a folder and saving it to the database.
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Create a new Category folder and register it in the database."
        )

        /// The name of the Category to create.
        @Argument(help: "The name of your new Category")
        var name: String?

        /// The path where the Category folder should be created.
        @Option(name: .shortAndLong, help: "The path to the parent folder where your new Category folder should be created.")
        var parentPath: String?

        func run() throws {
            try Nnapp.makeCategoryHandler().createCategory(name: name, parentPath: parentPath)
        }
    }
}


// MARK: - Group
extension Nnapp.Create {
    /// Creates a new Group folder under an existing Category and registers it in the database.
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Create a new Group folder and register it in the database."
        )

        /// The name of the Group to create.
        @Argument(help: "The name of your new Group")
        var name: String?

        /// The Category name to assign this Group to.
        @Option(name: .shortAndLong, help: "The name of the Category to assign to the new Group.")
        var category: String?

        func run() throws {
            try Nnapp.makeGroupHandler().createGroup(name: name, category: category)
        }
    }
}
