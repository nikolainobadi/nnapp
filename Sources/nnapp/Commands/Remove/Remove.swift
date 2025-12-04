//
//  Remove.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

/// Unregisters a Category, Group, Project, or Link from the CodeLaunch database.
/// Does not delete folders from disk.
extension Nnapp {
    struct Remove: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Unregister a Category, Group, or Project from the database.",
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
extension Nnapp.Remove {
    /// Removes a Category and all associated Groups and Projects from the database.
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Unregisters a Category (and all of its Groups and Projects) from the database"
        )

        /// The name of the Category to remove.
        @Argument(help: "The name of the Category to remove.")
        var name: String?

        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let browser = Nnapp.makeFolderBrowser(picker: picker)
            let handler = CategoryHandler(picker: picker, context: context, folderBrowser: browser)

            try handler.removeCategory(name: name)
        }
    }
}


// MARK: - Group
extension Nnapp.Remove {
    /// Removes a Group and all its Projects from the database.
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Unregisters a Group (and all of its Projects) from the database"
        )

        /// The name of the Group to remove.
        @Argument(help: "The name of the Group to remove.")
        var name: String?

        func run() throws {
            try Nnapp.makeGroupHandler().removeGroup(name: name)
        }
    }
}


// MARK: - Project
extension Nnapp.Remove {
    /// Removes a single Project from the database.
    /// Note: This does not remove the local folder from disk.
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Unregisters a Project from the database"
        )

        /// The name of the Project to remove.
        @Argument(help: "The name of the Project to remove.")
        var name: String?

        /// The quick-launch shortcut of the Project to remove.
        @Option(name: .shortAndLong, help: "The shortcut of the Project to remove.")
        var shortcut: String?

        func run() throws {
            try Nnapp.makeProjectHandler().removeProject(name: name, shortcut: shortcut)
        }
    }
}


// MARK: - Link
extension Nnapp.Remove {
    /// Removes a saved Project Link name from the configuration.
    struct Link: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Remove a saved Project Link"
        )

        /// The name of the Project Link to remove.
        @Argument(help: "The name of the Project Link to remove.")
        var name: String?

        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let existingNames = context.loadProjectLinkNames()

            if existingNames.isEmpty {
                print("No Project Links to remove")
            } else {
                let selection = try picker.requiredSingleSelection("Select a Project Link name to remove.", items: existingNames)
                let updatedNames = existingNames.filter { $0 != selection }

                context.saveProjectLinkNames(updatedNames)
            }
        }
    }
}
