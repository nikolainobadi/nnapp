//
//  Add.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

extension Nnapp {
    struct Add: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "",
            subcommands: [Category.self, Group.self, Project.self]
        )
    }
}


// MARK: - Category
extension Nnapp.Add {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "The path to an existing Category folder.")
        var path: String?
        
        func run() throws {
            let context = try makeContext()
            let handler = CategoryHandler(picker: picker, context: context)
            
            try handler.importCategory(path: path)
        }
    }
}


// MARK: - Group
extension Nnapp.Add {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "The path to an existing Group folder.")
        var path: String?
        
        @Option(name: .shortAndLong, help: "")
        var category: String?
        
        func run() throws {
            let context = try makeContext()
            let handler = GroupHandler(picker: picker, context: context)
            
            try handler.importGroup(path: path, category: category)
        }
    }
}


// MARK: - Project
extension Nnapp.Add {
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "The path to an existing Project folder.")
        var path: String?
        
        @Option(name: .shortAndLong, help: "")
        var group: String?
        
        @Option(name: .shortAndLong, help: "")
        var shortcut: String?
        
        func run() throws {
            let context = try makeContext()
            let handler = ProjectHandler(picker: picker, context: context)
            
            try handler.addProject(path: path, group: group, shortcut: shortcut)
        }
    }
}
