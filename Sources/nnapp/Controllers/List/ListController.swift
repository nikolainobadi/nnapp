//
//  ListController.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

import CodeLaunchKit

struct ListController {
    private let picker: any LaunchPicker
    private let loader: any LaunchListLoader
    private let console: any ConsoleOutput

    /// Initializes a new handler for list operations.
    /// - Parameters:
    ///   - picker: Utility for prompting user input and selections.
    ///   - context: Data context for loading categories, groups, and projects.
    ///   - console: Console output adapter for displaying information.
    init(picker: any LaunchPicker, loader: any LaunchListLoader, console: any ConsoleOutput) {
        self.picker = picker
        self.loader = loader
        self.console = console
    }
}


// MARK: - Hierarchy Navigation
extension ListController {
    func browseHierarchy() throws {
        let categories = try loader.loadCategories()
        
        if categories.isEmpty {
            console.printHeader("CodeLaunch")
            console.printLine("No Categories")
            console.printLine("")
            return
        }
        
        let nodes = LaunchTreeNode.categoryNodes(categories: categories)
        
        _ = picker.treeNavigation("Browse CodeLaunch Hierarchy", root: .init(displayName: "CodeLaunch", children: nodes), showPromptText: false)
    }
}


// MARK: - Category Operations
extension ListController {
    func selectAndDisplayCategory(name: String?) throws {
        let categories = try loader.loadCategories()
        let selectedCategory: LaunchCategory

        if let name, let category = categories.first(where: { name.matches($0.name) }) {
            selectedCategory = category
        } else {
            selectedCategory = try picker.requiredSingleSelection("Select a Category", items: categories)
        }

        console.printHeader(selectedCategory.name)
        displayCategoryDetails(selectedCategory)
        console.printLine("")
    }
    
    func displayCategoryDetails(_ category: LaunchCategory) {
        console.printHeader(category.name)
        console.printLine("path: \(category.path)")
        console.printLine("group count: \(category.groups.count)")
        console.printLine("")

        if !category.groups.isEmpty {
            for group in category.groups {
                console.printLine("\u{2022} \(group.name.bold.addingShortcut(group.shortcut))")

                if !group.projects.isEmpty {
                    for project in group.projects {
                        console.printLine("  - \(project.name.bold.addingShortcut(project.shortcut))")
                    }
                }
            }
        }
    }
}


// MARK: - Group Operations
extension ListController {
    func selectAndDisplayGroup(name: String?) throws {
        let groups = try loader.loadGroups()
        let selectedGroup: LaunchGroup

        if let name, let group = groups.first(where: { name.matches($0.name) || name.matches($0.shortcut) }) {
            selectedGroup = group
        } else {
            selectedGroup = try picker.requiredSingleSelection("Select a Group", items: groups)
        }

        console.printHeader(selectedGroup.name)
        displayGroupDetails(selectedGroup)
        console.printLine("")
    }

    func displayGroupDetails(_ group: LaunchGroup) {
        console.printHeader(group.name)
        console.printLine("category: \(group.categoryName ?? "NOT ASSIGNED")")
        console.printLine("group path: \(group.path ?? "NOT ASSIGNED")")
        console.printLine("project count: \(group.projects.count)")
        console.printLine("")

        if !group.projects.isEmpty {
            for project in group.projects {
                console.printLine("  - \(project.name.bold.addingShortcut(project.shortcut))")
            }
        }
    }
}


// MARK: - Project Operations
extension ListController {
    func selectAndDisplayProject(name: String?) throws {
        let projects = try loader.loadProjects()
        let selectedProject: LaunchProject

        if let name, let project = projects.first(where: { name.matches($0.name) || name.matches($0.shortcut) }) {
            selectedProject = project
        } else {
            selectedProject = try picker.requiredSingleSelection("Select a Project", items: projects)
        }

        console.printHeader(selectedProject.name)
        displayProjectDetails(selectedProject)
        console.printLine("")
    }

    func displayProjectDetails(_ project: LaunchProject) {
        console.printHeader(project.name)
        console.printLine("group: \(project.groupName ?? "NOT ASSIGNED")")
        console.printLine("shortcut: \(project.shortcut ?? "NOT ASSIGNED")")
        console.printLine("project type: \(project.type.name)")

        if let remote = project.remote {
            console.printLine("remote repository: \(remote.name) - \(remote.urlString)")
        }

        // TODO: - display links
    }
}


// MARK: - Link Operations
extension ListController {
    func displayProjectLinks() {
        let existingNames = loader.loadProjectLinkNames()

        if existingNames.isEmpty {
            console.printLine("No saved Project Link names")
        } else {
            console.printHeader("Project Link Names")

            for name in existingNames {
                console.printLine(name)
            }

            console.printLine("")
        }
    }
}


// MARK: - Private Methods
private extension ListController {
    func displayNodeDetails(_ node: LaunchTreeNode) {
        console.printLine("")

        switch node.type {
        case .category(let category,):
            displayCategoryDetails(category)
        case .group(let group):
            displayGroupDetails(group)
        case .project(let project):
            displayProjectDetails(project)
        }

        console.printLine("")
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
