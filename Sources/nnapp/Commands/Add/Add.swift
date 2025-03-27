//
//  Add.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import SwiftPicker
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
            let path = try path ?? picker.getRequiredInput("Enter the path to the folder you want to use.")
            let folder = try Folder(path: path)
            // TODO: - need to verify that category name is available
            let category = LaunchCategory(name: folder.name, path: folder.path)
            
            try context.saveCatgory(category)
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
            let path = try path ?? picker.getRequiredInput("Enter the path to the folder you want to use.")
            let folder = try Folder(path: path)
            // TODO: - need to verify that group name is available
            let category = try getCategory(named: category, context: context)
            let group = LaunchGroup(name: folder.name)
            
            try context.saveGroup(group, in: category)
        }
    }
}

// TODO: - need to encapsulate to reduce code duplication
private extension Nnapp.Add.Group {
    func getCategory(named name: String?, context: CodeLaunchContext) throws -> LaunchCategory {
        // TODO: - for now only handle existing categories
        let name = try name ?? picker.getRequiredInput("Enter the name of the category for this new group.")
        let categories = try context.loadCategories()
        
        if let category = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return category
        }
        
        throw NnappError.missingCategory
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
            let path = try path ?? picker.getRequiredInput("Enter the path to your project.")
            let folder = try Folder(path: path)
            // TODO: - need to verify that project name is available
            let group = try getGroup(named: group, context: context)
            // TODO: - need to verify that project shortcut is available
            let shortcut = try shortcut ?? picker.getRequiredInput("Enter the shortcut to launch this project.")
            let projectType = try getProjectType(folder: folder)
            let remote = getRemote(folder: folder)
            let otherLinks = getOtherLinks()
            let project = LaunchProject(name: folder.name, shortcut: shortcut, type: projectType, remote: remote, links: otherLinks)
            
            try context.saveProject(project, in: group)
        }
    }
}

private extension Nnapp.Add.Project {
    func getProjectType(folder: Folder) throws -> ProjectType {
        return .package // TODO: -
    }
    
    func getRemote(folder: Folder) -> ProjectLink? {
        return nil // TODO: -
    }
    
    func getOtherLinks() -> [ProjectLink] {
        return [] // TODO: -
    }
    
    func getGroup(named name: String?, context: CodeLaunchContext) throws -> LaunchGroup {
        // TODO: - for now only handle existing categories
        let name = try name ?? picker.getRequiredInput("Enter the name of the group for this project.")
        let groups = try context.loadGroups()
        
        if let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return group
        }
        
        throw NnappError.missingGroup
    }
}
