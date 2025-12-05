//
//  FinderHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

import NnShellKit
import CodeLaunchKit
import SwiftPickerKit

struct FinderHandler {
    private let shell: any Shell
    private let picker: any CommandLinePicker
    private let console: any ConsoleOutput
    private let loader: any FinderInfoLoader

    init(shell: any Shell, picker: any CommandLinePicker, loader: any FinderInfoLoader, console: any ConsoleOutput) {
        self.shell = shell
        self.picker = picker
        self.loader = loader
        self.console = console
    }
}


// MARK: - Browse All
extension FinderHandler {
    /// Opens an interactive browser to select and open any folder type.
    func browseAll() throws {
        let categories = try loader.loadCategories()

        if categories.isEmpty {
            console.printLine("No categories found. Create a category first.")
            return
        }

        let rootNodes = categories.map({ LaunchTreeNode.category($0, selectable: true) })
        let root = TreeNavigationRoot(displayName: "CodeLaunch", children: rootNodes)
        let selection = picker.treeNavigation("Browse and select folder to open", root: root, newScreen: true, showPromptText: false)

        guard let selectedNode = selection else {
            console.printLine("No selection made.")
            return
        }

        let path = try getPathFromNode(selectedNode)
        try openInFinder(path: path)
    }
}


// MARK: - Category Operations
extension FinderHandler {
    /// Opens a category folder in Finder.
    /// - Parameter name: Optional category name. If nil, prompts user to select.
    func openCategory(name: String?) throws {
        let path = try resolveCategoryPath(name: name)
        try openInFinder(path: path)
    }
}


// MARK: - Group Operations
extension FinderHandler {
    /// Opens a group folder in Finder.
    /// - Parameter name: Optional group name or shortcut. If nil, prompts user to select.
    func openGroup(name: String?) throws {
        let path = try resolveGroupPath(name: name)
        try openInFinder(path: path)
    }
}


// MARK: - Project Operations
extension FinderHandler {
    /// Opens a project folder in Finder.
    /// - Parameter name: Optional project name or shortcut. If nil, prompts user to select.
    func openProject(name: String?) throws {
        let path = try resolveProjectPath(name: name)
        try openInFinder(path: path)
    }
}


// MARK: - Private Methods
private extension FinderHandler {
    /// Opens the specified path in Finder.
    /// - Parameter path: The file system path to open.
    func openInFinder(path: String) throws {
        try shell.runAndPrint(bash: "open -a Finder \(path)")
    }
    
    func resolveCategoryPath(name: String?) throws -> String {
        let categories = try loader.loadCategories()

        if let name {
            if let category = categories.first(where: { name.matches($0.name) }) {
                return category.path
            }
            try picker.requiredPermission("Could not find a Category named \(name). Would you like to select from the list?")
        }

        return try picker.requiredSingleSelection("Select a Category", items: categories).path
    }
    
    func resolveProjectPath(name: String?) throws -> String {
        let projects = try loader.loadProjects()

        if let name {
            if let project = projects.first(where: { name.matches($0.name) || name.matches($0.shortcut) }),
               let path = project.folderPath {
                return path
            }
            try picker.requiredPermission("Could not find a Project with the name or shortcut \(name). Would you like to select from the list?")
        }

        let project = try picker.requiredSingleSelection("Select a Project", items: projects)

        guard let path = project.folderPath else {
            console.printLine("Could not resolve local path for \(project.name)")
            throw CodeLaunchError.missingProject
        }

        return path
    }
    
    func resolveGroupPath(name: String?) throws -> String {
        let groups = try loader.loadGroups()

        if let name {
            if let group = groups.first(where: { name.matches($0.name) || name.matches($0.shortcut) }),
               let path = group.path {
                return path
            }
            try picker.requiredPermission("Could not find a Group with the name or shortcut \(name). Would you like to select from the list?")
        }

        let group = try picker.requiredSingleSelection("Select a Group", items: groups)

        guard let path = group.path else {
            console.printLine("Could not resolve local path for \(group.name)")
            throw CodeLaunchError.missingGroup
        }

        return path
    }
    
    func getPathFromNode(_ node: LaunchTreeNode) throws -> String {
        switch node {
        case .category(let category, _):
            return category.path
        case .group(let group, _):
            guard let path = group.path else {
                throw CodeLaunchError.missingGroup
            }
            return path
        case .project(let project, _):
            guard let path = project.folderPath else {
                throw CodeLaunchError.missingProject
            }
            return path
        }
    }
}


// MARK: - Dependencies
protocol FinderInfoLoader {
    func loadCategories() throws -> [LaunchCategory]
    func loadGroups() throws -> [LaunchGroup]
    func loadProjects() throws -> [LaunchProject]
}
