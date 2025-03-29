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
            abstract: "Unregister a Category, Group, or Project from the database.",
            subcommands: [Category.self, Group.self, Project.self, Link.self]
        )
    }
}


// MARK: - Category
extension Nnapp.Remove {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Unregisters a Category (and all of its Groups and Projects) from the database"
        )
        
        @Argument(help: "The name of the Category to remove.")
        var name: String?
        
        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let handler = CategoryHandler(picker: picker, context: context)
            
            try handler.removeCategory(name: name)
        }
    }
}

// MARK: - Group
extension Nnapp.Remove {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Unregisters a Group (and all of its Projects) from the database"
        )
        
        @Argument(help: "The name of the Group to remove.")
        var name: String?
        
        func run() throws {
            try Nnapp.makeGroupHandler().removeGroup(name: name)
        }
    }
}


// MARK: - Project
extension Nnapp.Remove {
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Unregisters a Project from the database"
        )
        
        @Argument(help: "The name of the Project to remove.")
        var name: String?
        
        @Option(name: .shortAndLong, help: "The shortcut of the Project to remove.")
        var shortcut: String?
        
        func run() throws {
            let shell = Nnapp.makeShell()
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let handler = ProjectHandler(shell: shell, picker: picker, context: context)
            
            try handler.removeProject(name: name, shortcut: shortcut)
        }
    }
}


// MARK: - Link
extension Nnapp.Remove {
    struct Link: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Remote a saved Project Link"
        )
        
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
                let updatedNames = existingNames.filter({ $0 != selection })
                
                context.saveProjectLinkNames(updatedNames)
            }
        }
    }
}
