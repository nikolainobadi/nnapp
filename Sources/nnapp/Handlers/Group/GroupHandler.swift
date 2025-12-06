//
//  GroupHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct GroupHandler {
    private let store: any LaunchGroupStore
    private let picker: any LaunchPicker
    private let folderBrowser: any DirectoryBrowser
    private let categorySelector: any LaunchGroupCategorySelector
    private let fileSystem: any FileSystem
    
    init(
        store: any LaunchGroupStore,
        picker: any LaunchPicker,
        folderBrowser: any DirectoryBrowser,
        categorySelector: any LaunchGroupCategorySelector,
        fileSystem: any FileSystem
    ) {
        self.store = store
        self.picker = picker
        self.folderBrowser = folderBrowser
        self.categorySelector = categorySelector
        self.fileSystem = fileSystem
    }
}


// MARK: - Add
extension GroupHandler {
    @discardableResult
    func importGroup(path: String?, categoryName: String?) throws -> LaunchGroup {
        let category = try selectCategory(name: categoryName)
        let groupFolder = try selectGroupFolder(path: path, category: category)
        let name = try validateName(groupFolder.name, groups: category.groups)
        
        return try saveGroup(.new(name: name), in: category)
    }
    
    @discardableResult
    func createNewGroup(named name: String?, categoryName: String?) throws -> LaunchGroup {
        let category = try selectCategory(name: categoryName)
        let proposedName = try name ?? picker.getRequiredInput("Enter the name of your new group.")
        let name = try validateName(proposedName, groups: category.groups)
    
        return try saveGroup(.new(name: name), in: category)
    }
}


// MARK: - Remove
extension GroupHandler {
    func removeGroup(named name: String?) throws {
        let groups = try loadAllGroups()
        let groupToDelete: LaunchGroup
        
        if let name, let group = groups.first(where: { $0.name.lowercased() == name.lowercased() }) {
            groupToDelete = group
        } else {
            groupToDelete = try picker.requiredSingleSelection(
                "Select a group to delete",
                items: groups,
                layout: .twoColumnDynamic { makeGroupDetail(for: $0) }
            )
        }
        
        try picker.requiredPermission("Are you sure want to remove \(groupToDelete.name.yellow)?")
        try store.deleteGroup(groupToDelete)
    }
}


// MARK: - LaunchProjectGroupSelector
extension GroupHandler: ProjectGroupSelector {
    func getProjectGroup(project: LaunchProject) throws -> LaunchGroup? {
        return try loadAllGroups().first(where: { group in
            return group.projects.contains(where: { $0.name.matches(project.name) })
        })
    }
    
    func selectGroup(name: String?) throws -> LaunchGroup {
        let groups = try loadAllGroups()
        
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
            return try picker.requiredSingleSelection("Select a Group", items: groups, showSelectedItemText: false)
        }
    }
}


// MARK: - SetMainProject
extension GroupHandler {
    func setMainProject(group: String?) throws {
        let groups = try loadAllGroups()
        let selectedGroup: LaunchGroup
        
        if let group {
            if let foundGroup = groups.first(where: { $0.name.matches(group) || group.matches($0.shortcut) }) {
                selectedGroup = foundGroup
            } else {
                throw CodeLaunchError.missingGroup
            }
        } else {
            selectedGroup = try picker.requiredSingleSelection("Select a group to set the main project for", items: groups, showSelectedItemText: false)
        }
        
        let currentMainProject = selectedGroup.projects.first { project in
            guard let groupShortcut = selectedGroup.shortcut, let projectShortcut = project.shortcut else {
                return false
            }
            
            return groupShortcut.matches(projectShortcut)
        }
        
        if let currentMainProject {
            print("Current main project: \(currentMainProject.name.bold)")
            guard picker.getPermission("Would you like to change the main project?") else {
                print("No changes made.")
                return
            }
        } else {
            print("No main project is currently set for group '\(selectedGroup.name.bold)'")
        }
        
        // Get non-main projects
        let nonMainProjects = selectedGroup.projects.filter { project in
            guard let mainProject = currentMainProject else {
                return true
            }
            
            return project.name != mainProject.name
        }
            .sorted(by: { $0.name < $1.name })
        
        // Check if any non-main projects exist
        guard !nonMainProjects.isEmpty else {
            let message = currentMainProject != nil
                ? "No other projects exist in this group to switch to."
                : "No projects exist in this group. Add a project first using 'nnapp add project'."
            print(message)
            return
        }
        
        // Let user select new main project
        let newMainProject = try picker.requiredSingleSelection(
            "Select the new main project for '\(selectedGroup.name)'",
            items: nonMainProjects
        )
        
        // Determine shortcut to use
        let shortcutToUse: String
        if let groupShortcut = selectedGroup.shortcut {
            // Group has shortcut, use it
            shortcutToUse = groupShortcut
        } else if let projectShortcut = newMainProject.shortcut {
            // Group has no shortcut but new project does, use project's shortcut
            shortcutToUse = projectShortcut
        } else {
            // Neither has shortcut, prompt user
            shortcutToUse = try picker.getRequiredInput("Enter a shortcut for the main project and group:")
        }

        print(shortcutToUse)
        // TODO: -
        // Clear current main project's shortcut if it exists
//        if let currentMain = currentMainProject {
//            currentMain.shortcut = nil
//            try context.saveProject(currentMain, in: selectedGroup)
//        }
//
//        // Set new main project's shortcut and update group
//        newMainProject.shortcut = shortcutToUse
//        selectedGroup.shortcut = shortcutToUse
//        
//        // Save changes
//        try context.saveProject(newMainProject, in: selectedGroup)
//        try context.saveGroup(selectedGroup, in: selectedGroup.category!)
//        
//        print("Successfully set '\(newMainProject.name.bold)' as the main project for group '\(selectedGroup.name.bold)'")
    }
}


// MARK: - Private Methods
private extension GroupHandler {
    func selectCategory(name: String?) throws -> LaunchCategory {
        return try categorySelector.selectCategory(named: name)
    }
    
    func selectAssignGroupType() throws -> AssignGroupType {
        return try picker.requiredSingleSelection("How would you like to assign a Group to your Project?", items: AssignGroupType.allCases, showSelectedItemText: false)
    }
    
    func selectGroupFolder(path: String?, category: LaunchCategory) throws -> any Directory {
        if let path {
            return try fileSystem.directory(at: path)
        }
        
        let categoryFolder = try fileSystem.directory(at: category.path)
        let availableFolders = categoryFolder.subdirectories.filter { folder in
            !category.groups.map({ $0.name.lowercased() }).contains(folder.name.lowercased())
        }

        if !availableFolders.isEmpty, picker.getPermission("Would you like to select a subfolder of \(categoryFolder.name)?") {
            return try picker.requiredSingleSelection("Select a folder", items: availableFolders.map({ DirectoryContainer(directory: $0) }), showSelectedItemText: false).directory
        }

        return try folderBrowser.browseForDirectory(prompt: "Browse to select a folder to import as a Group")
    }
    
    func loadAllGroups() throws -> [LaunchGroup] {
        return try store.loadGroups()
    }
    
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory, groupFolder: Directory? = nil) throws -> LaunchGroup {
        if let groupFolder {
            try moveFolderIfNecessary(groupFolder, category: category)
        } else {
            try createNewGroupFolder(group: group, category: category)
        }
        
        try store.saveGroup(group, in: category)
        return group
    }
    
    func validateName(_ name: String, groups: [LaunchGroup]) throws -> String {
        if groups.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.groupNameTaken
        }
        
        return name
    }
    
    func moveFolderIfNecessary(_ folder: Directory, category: LaunchCategory) throws {
        let categoryFolder = try fileSystem.directory(at: category.path)
        
        if let existingFolder = try? categoryFolder.subdirectory(named: folder.name) {
            if existingFolder.path != folder.path {
                throw CodeLaunchError.groupFolderAlreadyExists
            }
            
            print("folder is already in the correct location")
            return
        }
        
        try folder.move(to: categoryFolder)
    }
    
    func createNewGroupFolder(group: LaunchGroup, category: LaunchCategory) throws {
        let categoryFolder = try fileSystem.directory(at: category.path)
        let subfolderNames = categoryFolder.subdirectories.map({ $0.name })

        if subfolderNames.contains(where: { $0.matches(group.name) }) {
            throw CodeLaunchError.groupFolderAlreadyExists
        }

        _ = try categoryFolder.createSubdirectory(named: group.name)
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
