//
//  ListHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

import CodeLaunchKit
import SwiftPickerKit

/// Coordinates list and display operations for CodeLaunch hierarchy.
struct ListHandler {
    private let picker: any CommandLinePicker
    private let loader: any LaunchListLoader
    private let console: any ConsoleOutput

    /// Initializes a new handler for list operations.
    /// - Parameters:
    ///   - picker: Utility for prompting user input and selections.
    ///   - context: Data context for loading categories, groups, and projects.
    ///   - console: Console output adapter for displaying information.
    init(picker: any CommandLinePicker, loader: any LaunchListLoader, console: any ConsoleOutput) {
        self.picker = picker
        self.loader = loader
        self.console = console
    }
}


// MARK: - Hierarchy Navigation
extension ListHandler {
    /// Displays an interactive tree navigation of the entire CodeLaunch hierarchy.
    func browseHierarchy() throws {
        let categories = try loader.loadCategories()
        
        if categories.isEmpty {
            console.printHeader("CodeLaunch")
            console.printLine("No Categories")
            console.printLine("")
            return
        }
        
        let rootNodes = categories.map({ LaunchTreeNode.category($0, selectable: false) })
        let root = TreeNavigationRoot(displayName: "CodeLaunch", children: rootNodes)
        let selection = picker.treeNavigation("Browse CodeLaunch Hierarchy", root: root, newScreen: true, showPromptText: false)
        
        if let selectedNode = selection {
            displayNodeDetails(selectedNode)
        }
    }
}


// MARK: - Category Operations
extension ListHandler {
    /// Selects and displays details for a specific category.
    /// - Parameter name: Optional category name. If nil, prompts user to select.
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

    /// Displays detailed information about a category.
    /// - Parameter category: The category to display.
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
extension ListHandler {
    /// Selects and displays details for a specific group.
    /// - Parameter name: Optional group name or shortcut. If nil, prompts user to select.
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

    /// Displays detailed information about a group.
    /// - Parameter group: The group to display.
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
extension ListHandler {
    /// Selects and displays details for a specific project.
    /// - Parameter name: Optional project name or shortcut. If nil, prompts user to select.
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

    /// Displays detailed information about a project.
    /// - Parameter project: The project to display.
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
extension ListHandler {
    /// Displays all saved project link names.
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
private extension ListHandler {
    func displayNodeDetails(_ node: LaunchTreeNode) {
        console.printLine("")

        switch node {
        case .category(let category, _):
            displayCategoryDetails(category)
        case .group(let group, _):
            displayGroupDetails(group)
        case .project(let project, _):
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
