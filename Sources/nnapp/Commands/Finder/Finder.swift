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
            abstract: "Open a Category/Group/Project folder in Finder"
        )
        
        @Argument(help: "The name of the Category/Group/Project or the shortcut for the Group/Project")
        var name: String?

        @Flag(help: "The folder type to open. Defaults to project (-c/--category, -g/--group, -p/--project)")
        var folderType: LaunchFolderType = .project
        
        func run() throws {
            let shell = Nnapp.makeShell()
            let folderPath = try getFolderPath(name: name, folderType: folderType)
            
            try shell.runAndPrint("open -a Finder \(folderPath)")
        }
    }
}


// MARK: - Private Methods
private extension Nnapp.Finder {
    func getFolderPath(name: String?, folderType: LaunchFolderType) throws -> String {
        let picker = Nnapp.makePicker()
        let context = try Nnapp.makeContext()
        
        switch folderType {
        case .category:
            let categories = try context.loadCategories()
            
            if let name {
                if let category = categories.first(where: { name.matches($0.name) }) {
                    return category.path
                }
                
                try picker.requiredPermission("Could not find a Category named \(name). Would you like to select from the list?")
            }
            
            return try picker.requiredSingleSelection("Select a Category", items: categories).path
        case .group:
            let groups = try context.loadGroups()
            
            if let name {
                if let group = groups.first(where: { name.matches($0.name) || name.matches($0.shortcut) }), let path = group.path {
                    return path
                }
                
                try picker.requiredPermission("Could not find a Group with the name or shortcut \(name). Would you like to select from the list?")
            }
            
            let group = try picker.requiredSingleSelection("Select a Group", items: groups)
            
            guard let path = group.path else {
                print("Could not resolve local path for \(group.name)")
                throw CodeLaunchError.missingGroup
            }
            
            return path
        case .project:
            let projects = try context.loadProjects()
            
            if let name {
                if let project = projects.first(where: { name.matches($0.name) || name.matches($0.shortcut) }), let path = project.folderPath {
                    return path
                }
                
                try picker.requiredPermission("Could not find a Project with the name or shortcut \(name). Would you like to select from the list?")
            }
            
            let project = try picker.requiredSingleSelection("Select a Project", items: projects)
            
            guard let path = project.folderPath else {
                print("Could not resolve local path for \(project.name)")
                throw CodeLaunchError.missingGroup
            }
            
            return path
        }
    }
}


// MARK: - Dependencies
enum LaunchFolderType: String, CaseIterable {
    case category, group, project
}

extension LaunchFolderType: EnumerableFlag {
    static func name(for value: LaunchFolderType) -> NameSpecification {
        switch value {
        case .category:
            return .shortAndLong
        case .group:
            return .shortAndLong
        case .project:
            return .shortAndLong
        }
    }
}

