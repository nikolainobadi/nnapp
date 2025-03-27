//
//  Create.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

extension Nnapp {
    struct Create: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "",
            subcommands: [Category.self, Group.self]
        )
    }
}

extension Nnapp.Create {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "")
        var name: String?
        
        @Option(name: .shortAndLong, help: "")
        var path: String?
        
        func run() throws {
            
        }
    }
}

extension Nnapp.Create {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        @Argument(help: "")
        var name: String?
        
        @Option(name: .shortAndLong, help: "")
        var path: String?
        
        @Option(name: .shortAndLong, help: "")
        var category: String?
        
        func run() throws {
            
        }
    }
}
