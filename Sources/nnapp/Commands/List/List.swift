//
//  List.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser
import SwiftPickerKit

extension Nnapp {
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display a list of all Categories, Groups, and Projects registered with CodeLaunch",
            subcommands: [
                Category.self,
                Group.self,
                Project.self,
                Link.self
            ]
        )

        func run() throws {
            let handler = try Nnapp.makeListHandler()
            try handler.browseHierarchy()
        }
    }
}


// MARK: - Category
extension Nnapp.List {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display details for a specific Category"
        )

        @Argument(help: "The Category name")
        var name: String?

        func run() throws {
            let handler = try Nnapp.makeListHandler()
            try handler.selectAndDisplayCategory(name: name)
        }
    }
}


// MARK: - Group
extension Nnapp.List {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display details for a specific Group"
        )

        @Argument(help: "The Group name or shortcut")
        var name: String?

        func run() throws {
            let handler = try Nnapp.makeListHandler()
            try handler.selectAndDisplayGroup(name: name)
        }
    }
}


// MARK: - Project
extension Nnapp.List {
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display details for a specific Project"
        )

        @Argument(help: "The Project name or shortcut")
        var name: String?

        func run() throws {
            let handler = try Nnapp.makeListHandler()
            try handler.selectAndDisplayProject(name: name)
        }
    }
}


// MARK: - Link
extension Nnapp.List {
    struct Link: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Displays the list of saved Project Link names."
        )

        func run() throws {
            let handler = try Nnapp.makeListHandler()
            handler.displayProjectLinks()
        }
    }
}
