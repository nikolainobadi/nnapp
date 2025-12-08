//
//  GroupController.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct GroupController {
    private let picker: any LaunchPicker
    private let fileSystem: any FileSystem
    private let groupService: any GroupService
    private let folderBrowser: any DirectoryBrowser
    private let categorySelector: any LaunchGroupCategorySelector
    
    init(
        picker: any LaunchPicker,
        fileSystem: any FileSystem,
        groupService: any GroupService,
        folderBrowser: any DirectoryBrowser,
        categorySelector: any LaunchGroupCategorySelector
    ) {
        self.picker = picker
        self.fileSystem = fileSystem
        self.groupService = groupService
        self.folderBrowser = folderBrowser
        self.categorySelector = categorySelector
    }
}


// MARK: - Add
extension GroupController {
    @discardableResult
    func importGroup(path: String?, categoryName: String?) throws -> LaunchGroup {
        let category = try selectCategory(name: categoryName)
        let selection = try selectGroupFolder(path: path, category: category)
        let name = try groupService.validateName(selection.folder.name, groups: category.groups)
        let confirmation = """
        Import \(name.yellow) into category \(category.name.yellow)?
        location: \(selection.folder.path.yellow)
        """
        
        try picker.requiredPermission(confirmation)
        
        return try groupService.saveGroup(.new(name: name), in: category, groupFolder: selection.folder, categoryFolder: selection.categoryFolder)
    }
    
    @discardableResult
    func createNewGroup(named name: String?, categoryName: String?) throws -> LaunchGroup {
        let category = try selectCategory(name: categoryName)
        let proposedName = try name ?? picker.getRequiredInput("Enter the name of your new group.")
        let name = try groupService.validateName(proposedName, groups: category.groups)
        let categoryFolder = try fileSystem.directory(at: category.path)
        let confirmation = """
        name: \(name.cyan)
        category: \(category.name.cyan)
        categoryLocation: \(categoryFolder.path.yellow)
        """
        
        try picker.confirmDetails(confirmText: "Create New Group", details: confirmation)
    
        return try groupService.saveGroup(.new(name: name), in: category, groupFolder: nil, categoryFolder: categoryFolder)
    }
}


// MARK: - Remove
extension GroupController {
    func removeGroup(named name: String?) throws {
        let categories = try groupService.loadCategories()
        let groups = categories.flatMap({ $0.groups })
        let groupToDelete: LaunchGroup
        
        if let name, let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
            groupToDelete = group
        } else {
            groupToDelete = try chooseExistingGroup(prompt: "Select a group from a category to remove.", categories: categories)
        }
        
        try picker.requiredPermission("Are you sure want to remove \(groupToDelete.name.yellow)?")
        try groupService.deleteGroup(groupToDelete)
    }
}


// MARK: - LaunchProjectGroupSelector
extension GroupController: ProjectGroupSelector {
    func getProjectGroup(project: LaunchProject) throws -> LaunchGroup? {
        return try groupService.projectGroup(for: project)
    }
    
    func selectGroup(name: String?) throws -> LaunchGroup {
        let categories = try groupService.loadCategories()
        let groups = categories.flatMap({ $0.groups })
        
        if let name {
            if let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
                return group
            }
            try picker.requiredPermission("Could not find a group named \(name.yellow). Would you like to add it?")
        }

        switch try selectAssignGroupType() {
        case .import:
            return try importGroup(path: nil, categoryName: nil)
        case .create:
            return try createNewGroup(named: name, categoryName: nil)
        case .select:
            return try chooseExistingGroup(prompt: "Select a group", categories: categories)
        }
    }
}


// MARK: - SetMainProject
extension GroupController {
    func setMainProject(group: String?) throws {
        let groups = try groupService.loadGroups()
        let selectedGroup = try resolveGroup(named: group, in: groups)
        guard let selection = try chooseNewMainProject(in: selectedGroup) else {
            return
        }

        let shortcutToUse = try determineShortcut(for: selectedGroup, newMain: selection.newMain)

        try persistMainProjectChange(
            group: selectedGroup,
            currentMain: selection.currentMain,
            newMain: selection.newMain,
            shortcut: shortcutToUse
        )
        
        print("Successfully set '\(selection.newMain.name.bold)' as the main project for group '\(selectedGroup.name.bold)'")
    }
}


// MARK: - Private Methods
private extension GroupController {
    func resolveGroup(named name: String?, in groups: [LaunchGroup]) throws -> LaunchGroup {
        if let name {
            if let foundGroup = groups.first(where: { $0.name.matches(name) || name.matches($0.shortcut) }) {
                return foundGroup
            }
            
            throw CodeLaunchError.missingGroup
        }

        return try picker.requiredSingleSelection("Select a group to set the main project for", items: groups, showSelectedItemText: false)
    }
    
    func chooseNewMainProject(in group: LaunchGroup) throws -> (currentMain: LaunchProject?, newMain: LaunchProject)? {
        let currentMain = groupService.mainProject(in: group)
        
        if let currentMain {
            print("Current main project: \(currentMain.name.bold)")
            guard picker.getPermission("Would you like to change the main project?") else {
                print("No changes made.")
                return nil
            }
        } else {
            print("No main project is currently set for group '\(group.name.bold)'")
        }
        
        let candidates = groupService.nonMainProjects(in: group, excluding: currentMain)
        guard !candidates.isEmpty else {
            let message = currentMain != nil
                ? "No other projects exist in this group to switch to."
                : "No projects exist in this group. Add a project first using 'nnapp add project'."
            print(message)
            return nil
        }
        
        let newMain = try picker.requiredSingleSelection(
            "Select the new main project for '\(group.name)'",
            items: candidates
        )
        
        return (currentMain, newMain)
    }
    
    func mainProject(in group: LaunchGroup) -> LaunchProject? {
        guard let groupShortcut = group.shortcut else {
            return nil
        }
        
        return group.projects.first(where: { project in
            guard let projectShortcut = project.shortcut else {
                return false
            }
            
            return groupShortcut.matches(projectShortcut)
        })
    }
    
    func nonMainProjects(in group: LaunchGroup, excluding currentMain: LaunchProject?) -> [LaunchProject] {
        return group.projects
            .filter { project in
                guard let currentMain else { return true }
                return project.name != currentMain.name
            }
            .sorted(by: { $0.name < $1.name })
    }
    
    func determineShortcut(for group: LaunchGroup, newMain: LaunchProject) throws -> String {
        if let groupShortcut = group.shortcut {
            return groupShortcut
        }
        
        if let projectShortcut = newMain.shortcut {
            return projectShortcut
        }
        
        return try picker.getRequiredInput("Enter a shortcut for the main project and group:")
    }
    
    func shouldClearPreviousShortcut(group: LaunchGroup, shortcutToUse: String) -> Bool {
        return groupService.shouldClearPreviousShortcut(group: group, shortcutToUse: shortcutToUse)
    }
    
    func persistMainProjectChange(group: LaunchGroup, currentMain: LaunchProject?, newMain: LaunchProject, shortcut: String) throws {
        try groupService.persistMainProjectChange(
            group: group,
            currentMain: currentMain,
            newMain: newMain,
            shortcut: shortcut
        )
    }
    
    func selectCategory(name: String?) throws -> LaunchCategory {
        return try categorySelector.selectCategory(named: name)
    }
    
    func selectAssignGroupType() throws -> AssignGroupType {
        return try picker.requiredSingleSelection("How would you like to assign a Group to your Project?", items: AssignGroupType.allCases, showSelectedItemText: false)
    }
    
    func selectGroupFolder(path: String?, category: LaunchCategory) throws -> (folder: Directory, categoryFolder: Directory) {
        let categoryFolder = try fileSystem.directory(at: category.path)

        if let path {
            return (try fileSystem.directory(at: path), categoryFolder)
        }
        
        let availableFolders = categoryFolder.subdirectories.filter { folder in
            !category.groups.map({ $0.name.lowercased() }).contains(folder.name.lowercased())
        }

        if !availableFolders.isEmpty, picker.getPermission("Would you like to select a subfolder of \(categoryFolder.name)?") {
            let selected = try picker.requiredSingleSelection("Select a folder", items: availableFolders.map({ DirectoryContainer(directory: $0) }), showSelectedItemText: false).directory
            return (selected, categoryFolder)
        }

        let browsed = try folderBrowser.browseForDirectory(prompt: "Browse to select a folder to import as a Group")
        return (browsed, categoryFolder)
    }
    
    func chooseExistingGroup(prompt: String, categories: [LaunchCategory]) throws -> LaunchGroup {
        let nodes = LaunchTreeNode.categoryNodes(categories: categories, canSelect: false, includeProjects: false)
        
        guard let selection = picker.treeNavigation(prompt, root: .init(displayName: "Code Launch Groups", children: nodes)) else {
            throw CodeLaunchError.missingGroup
        }
        
        switch selection.type {
        case .group(let group):
            return group
        default:
            throw CodeLaunchError.missingGroup
        }
    }

    func makeGroupDetail(for group: LaunchGroup) -> String {
        let category = categorySelector.getCategory(group: group)
        let categoryName = category?.name ?? "Not assigned"
        let groupPath = category?.path.appendingPathComponent(group.name)
        let path = groupPath?.yellow ?? "path not set"
        let shortcut = group.shortcut ?? "None"

        return """
        project count: \(group.projects.count)
        shortcut: \(shortcut)
        category: \(categoryName)
        path: \(path)
        """
    }
}
