//
//  Add.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import CodeLaunchKit
import ArgumentParser

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
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Register a new Category by importing an existing folder from your computer."
        )

        @Argument(help: "The path to an existing Category folder.")
        var path: String?

        func run() throws {
            try Nnapp.makeCategoryController().importCategory(path: path)
        }
    }
}


// MARK: - Group
extension Nnapp.Add {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Register a new Group by importing an existing folder from your computer."
        )

        @Argument(help: "The path to an existing Group folder.")
        var path: String?

        @Option(name: .shortAndLong, help: "The name of the Category to assign this Group to.")
        var category: String?

        func run() throws {
            try Nnapp.makeGroupController().importGroup(path: path, categoryName: category)
        }
    }
}


// MARK: - Project
extension Nnapp.Add {
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Register a new Project by importing an existing folder from your computer."
        )

        @Argument(help: "The path to an existing Project folder.")
        var path: String?

        @Option(name: .shortAndLong, help: "The name of the Group to assign this Project to.")
        var group: String?

        @Option(name: .shortAndLong, help: "The shortcut used to quickly launch this project.")
        var shortcut: String?

        @Flag(name: .customLong("main-project"), help: "Syncs the new Project shortcut with the Group shortcut")
        var isMainProject: Bool = false
        
        @Flag(name: .customLong("from-desktop"), help: "Select from valid Xcode projects or Swift packages on the Desktop")
        var fromDesktop: Bool = false

        func run() throws {
            try Nnapp.makeProjectController().addProject(
                path: path,
                shortcut: shortcut,
                groupName: group,
                isMainProject: isMainProject,
                fromDesktop: fromDesktop
            )
        }
    }
}


// MARK: - Link
extension Nnapp.Add {
    struct Link: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Add a new Project Link option to your saved list"
        )

        @Argument(help: "The name of the new link option")
        var name: String?

        func run() throws {
            // TODO: - should encapsulate this logic
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeRepository()
            let existingList = context.loadProjectLinkNames()
            let name = try name ?? picker.getRequiredInput("Enter the name of your new Project Link option.")

            if existingList.contains(where: { $0.matches(name) }) {
                throw CodeLaunchError.projectLinkNameTaken
            }

            context.saveProjectLinkNames(existingList + [name])
        }
    }
}
