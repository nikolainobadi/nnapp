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
            let categories = try context.loadCategories()
            
            var categoryToDelete: LaunchCategory
            
            if let name, let category = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
                categoryToDelete = category
            } else {
                categoryToDelete = try picker.requiredSingleSelection("Select a category to remove", items: categories)
            }
            
            // TODO: - maybe display group count with project count
            try picker.requiredPermission("Are you sure want to remove \(categoryToDelete.name.yellow)?")
            
            try context.deleteCategory(categoryToDelete)
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
            let groups = try context.loadGroups()
            
            var groupToDelete: LaunchGroup
            
            if let name, let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
                groupToDelete = group
            } else {
                groupToDelete = try picker.requiredSingleSelection("Select a group to delete", items: groups)
            }
            
            // TODO: - maybe display project count
            try picker.requiredPermission("Are you sure want to remove \(groupToDelete.name.yellow)?")
            
            try context.deleteGroup(groupToDelete)
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
            let projects = try context.loadProjects()
            
            var projectToDelete: LaunchProject
            
            if let name, let project = projects.first(where: { $0.name.lowercased() == name.lowercased() }) {
                projectToDelete = project
            } else if let project = getProject(shortcut: shortcut, projects: projects) {
                projectToDelete = project
            } else {
                projectToDelete = try picker.requiredSingleSelection("Select a Project to remove", items: projects)
            }
            
            // TODO: - maybe indicate that this is different from evicting?
            try picker.requiredPermission("Are you sure want to remove \(projectToDelete.name.yellow)?")
            try context.deleteProject(projectToDelete)
        }
    }
}

private extension Nnapp.Remove.Project {
    func getProject(shortcut: String?, projects: [LaunchProject]) -> LaunchProject? {
        guard let shortcut else {
            return nil
        }
        
        return projects.first { project in
            guard let projectShortcut = project.shortcut else {
                return false
            }
            
            return projectShortcut.lowercased() == shortcut.lowercased()
        }
    }
}
