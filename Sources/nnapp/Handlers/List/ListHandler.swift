//
//  ListHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

import SwiftPickerKit

/// Coordinates list and display operations for CodeLaunch hierarchy.
struct ListHandler {
    private let picker: any CommandLinePicker
    private let context: CodeLaunchContext

    /// Initializes a new handler for list operations.
    /// - Parameters:
    ///   - picker: Utility for prompting user input and selections.
    ///   - context: Data context for loading categories, groups, and projects.
    init(picker: any CommandLinePicker, context: CodeLaunchContext) {
        self.picker = picker
        self.context = context
    }
}


// MARK: - Hierarchy Navigation
extension ListHandler {
    /// Displays an interactive tree navigation of the entire CodeLaunch hierarchy.
    func browseHierarchy() throws {
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


// MARK: - Category Operations
extension ListHandler {
    /// Selects and displays details for a specific category.
    /// - Parameter name: Optional category name. If nil, prompts user to select.
    func selectAndDisplayCategory(name: String?) throws {
        let categories = try context.loadCategories()
        let selectedCategory: LaunchCategory

        if let name, let category = categories.first(where: { name.matches($0.name) }) {
            selectedCategory = category
        } else {
            selectedCategory = try picker.requiredSingleSelection("Select a Category", items: categories)
        }

        printHeader(selectedCategory.name)
        displayCategoryDetails(selectedCategory)
        print("")
    }

    /// Displays detailed information about a category.
    /// - Parameter category: The category to display.
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
}


// MARK: - Group Operations
extension ListHandler {
    /// Selects and displays details for a specific group.
    /// - Parameter name: Optional group name or shortcut. If nil, prompts user to select.
    func selectAndDisplayGroup(name: String?) throws {
        let groups = try context.loadGroups()
        let selectedGroup: LaunchGroup

        if let name, let group = groups.first(where: { name.matches($0.name) || name.matches($0.shortcut) }) {
            selectedGroup = group
        } else {
            selectedGroup = try picker.requiredSingleSelection("Select a Group", items: groups)
        }

        printHeader(selectedGroup.name)
        displayGroupDetails(selectedGroup)
        print("")
    }

    /// Displays detailed information about a group.
    /// - Parameter group: The group to display.
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
}


// MARK: - Project Operations
extension ListHandler {
    /// Selects and displays details for a specific project.
    /// - Parameter name: Optional project name or shortcut. If nil, prompts user to select.
    func selectAndDisplayProject(name: String?) throws {
        let projects = try context.loadProjects()
        let selectedProject: LaunchProject

        if let name, let project = projects.first(where: { name.matches($0.name) || name.matches($0.shortcut) }) {
            selectedProject = project
        } else {
            selectedProject = try picker.requiredSingleSelection("Select a Project", items: projects)
        }

        printHeader(selectedProject.name)
        displayProjectDetails(selectedProject)
        print("")
    }

    /// Displays detailed information about a project.
    /// - Parameter project: The project to display.
    func displayProjectDetails(_ project: LaunchProject) {
        printHeader(project.name)
        print("group: \(project.group?.name ?? "NOT ASSIGNED")")
        print("shortcut: \(project.shortcut ?? "NOT ASSIGNED")")
        print("project type: \(project.type.name)")

        if let remote = project.remote {
            print("remote repository: \(remote.name) - \(remote.urlString)")
        }

        // TODO: - display links
    }
}


// MARK: - Link Operations
extension ListHandler {
    /// Displays all saved project link names.
    func displayProjectLinks() {
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


// MARK: - Private Methods
private extension ListHandler {
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
}


// MARK: - Dependencies
private func printHeader(_ title: String) {
    print("\n---------- \(title.bold.underline) ----------", terminator: "\n\n")
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
