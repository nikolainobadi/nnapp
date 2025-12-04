//
//  Add.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

/// Adds a new Category, Group, Project, or Link from an existing folder on disk.
/// This command is used to register existing local resources with CodeLaunch.
extension Nnapp {
    struct Add: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Register a Category, Group, or Project from an existing folder on your computer.",
            subcommands: [
                Category.self,
                Group.self,
                Project.self,
                Link.self
            ]
        )
    }
}


// MARK: - Category
extension Nnapp.Add {
    /// Imports a folder as a new Category and registers it in the database.
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Register a new Category by importing an existing folder from your computer."
        )

        /// The full path to the folder you want to register as a Category.
        @Argument(help: "The path to an existing Category folder.")
        var path: String?

        func run() throws {
            try Nnapp.makeCategoryHandler().importCategory(path: path)
        }
    }
}


// MARK: - Group
extension Nnapp.Add {
    /// Imports a folder as a new Group and registers it under a Category.
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Register a new Group by importing an existing folder from your computer."
        )

        /// The path to the folder you want to register as a Group.
        @Argument(help: "The path to an existing Group folder.")
        var path: String?

        /// The name of the Category to associate this Group with.
        @Option(name: .shortAndLong, help: "The name of the Category to assign this Group to.")
        var category: String?

        func run() throws {
            try Nnapp.makeGroupHandler().importGroup(path: path, category: category)
        }
    }
}


// MARK: - Project
extension Nnapp.Add {
    /// Imports a folder as a new Project and registers it under a Group.
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Register a new Project by importing an existing folder from your computer."
        )

        /// The path to the folder you want to register as a Project.
        @Argument(help: "The path to an existing Project folder.")
        var path: String?

        /// The name of the Group to assign this project to.
        @Option(name: .shortAndLong, help: "The name of the Group to assign this Project to.")
        var group: String?

        /// The quick-launch shortcut to assign to the project.
        @Option(name: .shortAndLong, help: "The shortcut used to quickly launch this project.")
        var shortcut: String?

        /// Whether this is the primary project in its Group (syncs shortcut with Group).
        @Flag(name: .customLong("main-project"), help: "Syncs the new Project shortcut with the Group shortcut")
        var isMainProject: Bool = false
        
        /// Whether to select from projects on the Desktop.
        @Flag(name: .customLong("from-desktop"), help: "Select from valid Xcode projects or Swift packages on the Desktop")
        var fromDesktop: Bool = false

        func run() throws {
            try Nnapp.makeProjectHandler().addProject(
                path: path,
                group: group,
                shortcut: shortcut,
                isMainProject: isMainProject,
                fromDesktop: fromDesktop
            )
        }
    }
}


// MARK: - Link
extension Nnapp.Add {
    /// Adds a new named project link (e.g. website, docs, analytics) to be reused when creating projects.
    struct Link: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Add a new Project Link option to your saved list"
        )

        /// The name of the link option to add (e.g. "Firebase", "Docs").
        @Argument(help: "The name of the new link option")
        var name: String?

        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let existingList = context.loadProjectLinkNames()

            let name = try name ?? picker.getRequiredInput("Enter the name of your new Project Link option.")

            if existingList.contains(where: { $0.matches(name) }) {
                throw CodeLaunchError.projectLinkNameTaken
            }

            context.saveProjectLinkNames(existingList + [name])
        }
    }
}
