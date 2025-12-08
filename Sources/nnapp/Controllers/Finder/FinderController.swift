//
//  FinderController.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

import CodeLaunchKit

struct FinderController {
    private let shell: any LaunchShell
    private let picker: any LaunchPicker
    private let console: any ConsoleOutput
    private let loader: any FinderInfoLoader

    init(shell: any LaunchShell, picker: any LaunchPicker, loader: any FinderInfoLoader, console: any ConsoleOutput) {
        self.shell = shell
        self.picker = picker
        self.loader = loader
        self.console = console
    }
}


// MARK: - Browse All
extension FinderController {
    func browseAll() throws {
        let categories = try loader.loadCategories()

        if categories.isEmpty {
            console.printLine("No categories found. Create a category first.")
            return
        }

        let rootNodes = categories.map({ LaunchTreeNode.category($0, selectable: true) })
        let selection = picker.treeNavigation("Browse and select folder to open", root: .init(displayName: "CodeLaunch", children: rootNodes), showPromptText: false)

        guard let selectedNode = selection else {
            console.printLine("No selection made.")
            return
        }

        let path = try getPathFromNode(selectedNode)
        try openInFinder(path: path)
    }
}


// MARK: - Category Operations
extension FinderController {
    func openCategory(name: String?) throws {
        let path = try resolveCategoryPath(name: name)
        try openInFinder(path: path)
    }
}


// MARK: - Group Operations
extension FinderController {
    func openGroup(name: String?) throws {
        let path = try resolveGroupPath(name: name)
        try openInFinder(path: path)
    }
}


// MARK: - Project Operations
extension FinderController {
    func openProject(name: String?) throws {
        let path = try resolveProjectPath(name: name)
        try openInFinder(path: path)
    }
}


// MARK: - Private Methods
private extension FinderController {
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
