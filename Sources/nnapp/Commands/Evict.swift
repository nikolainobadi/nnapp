//
//  Evict.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

extension Nnapp {
    struct Evict: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Deletes a Project folder from your computer but maintains the quick-launch information to allow for easy cloning when launching the Project."
        )
        
        @Argument(help: "The name of the Project to evict.")
        var name: String?
        
        @Option(name: .shortAndLong, help: "The shortcut of the Project to evict.")
        var shortcut: String?
    
        func run() throws {
            let controller = try Nnapp.makeProjectController()
            if name != nil || shortcut != nil {
                try controller.evictProject(name: name, shortcut: shortcut)
            } else {
                try controller.evictProjects()
            }
        }
    }
}
