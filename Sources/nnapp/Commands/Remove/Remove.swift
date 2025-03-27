//
//  Remove.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

extension Nnapp {
    struct Remove: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "",
            subcommands: [Category.self, Group.self, Project.self]
        )
    }
}


// MARK: - Category
extension Nnapp.Remove {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "")
        var name: String?
        
        func run() throws {
            let context = try makeContext()
            let handler = CategoryHandler(picker: picker, context: context)
            
            try handler.removeCategory(name: name)
        }
    }
}

// MARK: - Group
extension Nnapp.Remove {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "")
        var name: String?
        
        func run() throws {
            let context = try makeContext()
            let handler = GroupHandler(picker: picker, context: context)
            
            try handler.removeGroup(name: name)
        }
    }
}

// MARK: - Project
extension Nnapp.Remove {
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "")
        var name: String?
        
        @Option(name: .shortAndLong, help: "")
        var shortcut: String?
        
        func run() throws {
            let context = try makeContext()
            let handler = ProjectHandler(picker: picker, context: context)
            
            try handler.removeProject(name: name, shortcut: shortcut)
        }
    }
}
