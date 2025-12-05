//
//  Finder.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import ArgumentParser

extension Nnapp {
    struct Finder: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open a Category/Group/Project folder in Finder",
            subcommands: [
                Category.self,
                Group.self,
                Project.self
            ]
        )

        func run() throws {
            try Nnapp.makeFinderHandler().browseAll()
        }
    }
}


// MARK: - Category
extension Nnapp.Finder {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open a Category folder in Finder"
        )

        @Argument(help: "The Category name")
        var name: String?

        func run() throws {
            try Nnapp.makeFinderHandler().openCategory(name: name)
        }
    }
}


// MARK: - Group
extension Nnapp.Finder {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open a Group folder in Finder"
        )

        @Argument(help: "The Group name or shortcut")
        var name: String?

        func run() throws {
            try Nnapp.makeFinderHandler().openGroup(name: name)
        }
    }
}


// MARK: - Project
extension Nnapp.Finder {
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open a Project folder in Finder"
        )

        @Argument(help: "The Project name or shortcut")
        var name: String?

        func run() throws {
            try Nnapp.makeFinderHandler().openProject(name: name)
        }
    }
}
