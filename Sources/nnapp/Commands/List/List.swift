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
            let picker = makePicker()
            let context = try makeContext()
            let categories = try context.loadCategories()

            if categories.isEmpty {
                print("\n---------- CodeLaunch ----------", terminator: "\n\n")
                print("No Categories")
                print("")
                return
            }

            let rootNodes = categories.map({ LaunchTreeNode.category($0, selectable: false) })
            let selection = picker.treeNavigation("Browse CodeLaunch Hierarchy", rootItems: rootNodes, showPromptText: false)

            if let selectedNode = selection {
                displayNodeDetails(selectedNode)
            }
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
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let categories = try context.loadCategories()
            var selectedCategory: LaunchCategory
            
            if let name, let category = categories.first(where: { name.matches($0.name) }) {
                selectedCategory = category
            } else {
                selectedCategory = try picker.requiredSingleSelection("Select a Category", items: categories)
            }
            
            printHeader(selectedCategory.name)
            
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
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let groups = try context.loadGroups()
            var selectedGroup: LaunchGroup
            
            if let name, let group = groups.first(where: { name.matches($0.name) || name.matches($0.shortcut) }) {
                selectedGroup = group
            } else {
                selectedGroup = try picker.requiredSingleSelection("Select a Group", items: groups)
            }
            
            printHeader(selectedGroup.name)
            
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
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let projects = try context.loadProjects()
            var selectedProject: LaunchProject
            
            if let name, let project = projects.first(where: { name.matches($0.name) || name.matches($0.shortcut) }) {
                selectedProject = project
            } else {
                selectedProject = try picker.requiredSingleSelection("Select a Project", items: projects)
            }
            
            printHeader(selectedProject.name)
            
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


// MARK: - Link
extension Nnapp.List {
    struct Link: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Displays the list of saved Project Link names."
        )
        
        func run() throws {
            let context = try Nnapp.makeContext()
            let existingNames = context.loadProjectLinkNames()
            
            if existingNames.isEmpty {
                print("No saved Project Link names")
            } else {
                printHeader("Project Link Names")
                
                for name in existingNames {
                    print(name)
                }
                
                print("")
            }
        }
    }
}


// MARK: - Private Methods
private extension Nnapp.List {
    func displayNodeDetails(_ node: LaunchTreeNode) {
        print("")

        switch node {
        case .category(let category, _):
            displayCategoryDetails(category)
        case .group(let group, _):
            displayGroupDetails(group)
        case .project(let project, _):
            displayProjectDetails(project)
        }

        print("")
    }

    func displayCategoryDetails(_ category: LaunchCategory) {
        printHeader(category.name)
        print("path: \(category.path)")
        print("group count: \(category.groups.count)", terminator: "\n\n")

        if !category.groups.isEmpty {
            for group in category.groups {
                print("\u{2022} \(group.name.bold.addingShortcut(group.shortcut))")

                if !group.projects.isEmpty {
                    for project in group.projects {
                        print("  - \(project.name.bold.addingShortcut(project.shortcut))")
                    }
                }
            }
        }
    }

    func displayGroupDetails(_ group: LaunchGroup) {
        printHeader(group.name)
        print("category: \(group.category?.name ?? "NOT ASSIGNED")")
        print("group path: \(group.path ?? "NOT ASSIGNED")")
        print("project count: \(group.projects.count)", terminator: "\n\n")

        if !group.projects.isEmpty {
            for project in group.projects {
                print("  - \(project.name.bold.addingShortcut(project.shortcut))")
            }
        }
    }

    func displayProjectDetails(_ project: LaunchProject) {
        printHeader(project.name)
        print("group: \(project.group?.name ?? "NOT ASSIGNED")")
        print("shortcut: \(project.shortcut ?? "NOT ASSIGNED")")
        print("project type: \(project.type.name)")

        if let remote = project.remote {
            print("remote repository: \(remote.name) - \(remote.urlString)")
        }
    }
}


// MARK: - Extension Dependencies
private extension String {
    func addingShortcut(_ shortcut: String?) -> String {
        guard let shortcut else {
            return self
        }
        
        return "\(self), shortcut: \(shortcut)"
    }
}


// MARK: - Tree Navigation Node
private enum LaunchTreeNode: TreeNodePickerItem {
    case category(LaunchCategory, selectable: Bool)
    case group(LaunchGroup, selectable: Bool)
    case project(LaunchProject, selectable: Bool)

    var displayName: String {
        switch self {
        case .category(let category, _):
            return category.name
        case .group(let group, _):
            if let shortcut = group.shortcut {
                return "\(group.name) [\(shortcut)]"
            }
            return group.name
        case .project(let project, _):
            if let shortcut = project.shortcut {
                return "\(project.name) [\(shortcut)]"
            }
            return project.name
        }
    }

    var hasChildren: Bool {
        switch self {
        case .category(let category, _):
            return !category.groups.isEmpty
        case .group(let group, _):
            return !group.projects.isEmpty
        case .project:
            return false
        }
    }

    func loadChildren() -> [LaunchTreeNode] {
        switch self {
        case .category(let category, let selectable):
            return category.groups.map { .group($0, selectable: selectable) }
        case .group(let group, let selectable):
            return group.projects.map { .project($0, selectable: selectable) }
        case .project:
            return []
        }
    }

    var metadata: TreeNodeMetadata? {
        switch self {
        case .category:
            return .init(icon: "🗂️")
        case .group:
            return .init(icon: "📁")
        case .project(let project, _):
            let icon: String
            switch project.type {
            case .project:
                icon = "📄"
            case .package:
                icon = "📦"
            case .workspace:
                icon = "🧰"
            }
            return .init(icon: icon)
        }
    }

    var isSelectable: Bool {
        switch self {
        case .category(_, let selectable),
             .group(_, let selectable),
             .project(_, let selectable):
            return selectable
        }
    }
}


// MARK: - Helpers Print Methods
private func printHeader(_ title: String) {
    print("\n---------- \(title.bold.underline) ----------", terminator: "\n\n")
}
