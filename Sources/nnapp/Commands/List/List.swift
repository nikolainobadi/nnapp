//
//  List.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

extension Nnapp {
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display a list of all Categories, Groups, and Projects registered with CodeLaunch",
            subcommands: [Category.self]
        )
        
        func run() throws {
            let context = try makeContext()
            
            let categories = try context.loadCategories()
            
            print("\n---------- CodeLaunch ----------", terminator: "\n\n")
            
            if categories.isEmpty {
                print("No Categories")
            } else {
                for category in categories {
                    print(category.name.bold.underline)
                    
                    if category.groups.isEmpty {
                        print("")
                    } else {
                        for group in category.groups {
                            print("\u{2022} \(group.name.bold.addingShortcut(group.shortcut))")
                            
                            if group.projects.isEmpty {
                                print("")
                            } else {
                                for project in group.projects {
                                    print("  - \(project.name.bold.addingShortcut(project.shortcut))")
                                }
                            }
                        }
                    }
                }
            }
            
            print("")
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
            let context = try makeContext()
            let categories = try context.loadCategories()
            var selectedCategory: LaunchCategory
            
            if let name, let category = categories.first(where: { name.matches($0.name) }) {
                selectedCategory = category
            } else {
                selectedCategory = try picker.requiredSingleSelection("Select a Category", items: categories)
            }
            
            print("\n---------- \(selectedCategory.name.bold.underline) ----------", terminator: "\n\n")
            
            print("path: \(selectedCategory.path)")
            print("group Count: \(selectedCategory.groups.count)", terminator: "\n\n")
            
            if selectedCategory.groups.isEmpty {
                print("")
            } else {
                for group in selectedCategory.groups {
                    print("\u{2022} \(group.name.bold.addingShortcut(group.shortcut))")
                    
                    if group.projects.isEmpty {
                        print("")
                    } else {
                        for project in group.projects {
                            print("  - \(project.name.bold.addingShortcut(project.shortcut))")
                        }
                    }
                }
            }
            
            print("")
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
            let context = try makeContext()
            let groups = try context.loadGroups()
            var selectedGroup: LaunchGroup
            
            if let name, let group = groups.first(where: { name.matches($0.name) || name.matches($0.shortcut) }) {
                selectedGroup = group
            } else {
                selectedGroup = try picker.requiredSingleSelection("Select a Group", items: groups)
            }
            
            print("\n---------- \(selectedGroup.name.bold.underline) ----------", terminator: "\n\n")
            
            print("category: \(selectedGroup.category?.name ?? "NOT ASSIGNED")")
            print("group path: \(selectedGroup.path ?? "NOT ASSIGNED")")
            print("project count: \(selectedGroup.projects.count)", terminator: "\n\n")
            
            if selectedGroup.projects.isEmpty {
                print("")
            } else {
                for project in selectedGroup.projects {
                    print("  - \(project.name.bold.addingShortcut(project.shortcut))")
                }
            }
            
            print("")
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
            let context = try makeContext()
            let projects = try context.loadProjects()
            var selectedProject: LaunchProject
            
            if let name, let project = projects.first(where: { name.matches($0.name) || name.matches($0.shortcut) }) {
                selectedProject = project
            } else {
                selectedProject = try picker.requiredSingleSelection("Select a Project", items: projects)
            }
            
            print("\n---------- \(selectedProject.name.bold.underline) ----------", terminator: "\n\n")
            
            print("group: \(selectedProject.group?.name ?? "NOT ASSIGNED")")
            print("shortcut: \(selectedProject.shortcut ?? "NOT ASSIGNED")")
            print("project type: \(selectedProject.type.name)")
            
            if let remote = selectedProject.remote {
                print("remote repository: \(remote.name) - \(remote.urlString)")
            }
            
            // TODO: - display links
            
            print("")
        }
    }
}


// MARK: - Extension Dependencies
fileprivate extension String {
    func addingShortcut(_ shortcut: String?) -> String {
        guard let shortcut else {
            return self
        }
        
        return "\(self), shortcut: \(shortcut)"
    }
}
