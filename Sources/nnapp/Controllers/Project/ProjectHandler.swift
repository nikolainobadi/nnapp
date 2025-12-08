//
//  ProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct ProjectHandler {
    private let shell: any LaunchShell
    private let picker: any LaunchPicker
    private let fileSystem: any FileSystem
    private let folderBrowser: any DirectoryBrowser
    private let groupSelector: any ProjectGroupSelector
    private let infoLoader: any ProjectInfoLoader
    private let projectService: any ProjectService
    
    init(
        shell: any LaunchShell,
        infoLoader: any ProjectInfoLoader,
        projectService: any ProjectService,
        picker: any LaunchPicker,
        fileSystem: any FileSystem,
        folderBrowser: any DirectoryBrowser,
        groupSelector: any ProjectGroupSelector
    ) {
        self.shell = shell
        self.picker = picker
        self.fileSystem = fileSystem
        self.folderBrowser = folderBrowser
        self.groupSelector = groupSelector
        self.infoLoader = infoLoader
        self.projectService = projectService
    }
}


// MARK: - Add
extension ProjectHandler {
    func addProject(path: String?, shortcut: String?, groupName: String?, isMainProject: Bool, fromDesktop: Bool) throws {
        let group = try selectGroup(named: groupName)
        let projectFolder = try selectProjectFolder(path: path, group: group, fromDesktop: fromDesktop)
        let info = try selectProjectInfo(folder: projectFolder.folder, shortcut: shortcut, group: group, isMainProject: isMainProject)
        let project = LaunchProject(info: info, type: projectFolder.type)
        
        try moveFolderIfNecessary(projectFolder.folder, parentPath: group.path)
        try saveProject(project, in: group, isMainProject: isMainProject)
    }
}


// MARK: - Remove
extension ProjectHandler {
    func removeProject(name: String?, shortcut: String?) throws {
        let projectToDelete = try getProjectToDelete(name: name, shortcut: shortcut)
        
        // TODO: - maybe indicate that this is different from evicting?
        try picker.requiredPermission("Are you sure want to remove \(projectToDelete.name.yellow)?")
        try deleteProject(projectToDelete)
    }
}


// MARK: - Evict (placeholder)
extension ProjectHandler {
    func evictProject(name: String?, shortcut: String?) throws {
        // TODO: - implement eviction flow (trash folder but keep registration)
        throw CodeLaunchError.invalidInput
    }
}


// MARK: - Private Methods
private extension ProjectHandler {
    func selectGroup(named name: String?) throws -> LaunchGroup {
        return try groupSelector.selectGroup(name: name)
    }
    
    func selectProjectFolder(path: String?, group: LaunchGroup, fromDesktop: Bool) throws -> ProjectFolder {
        let folderSelector = ProjectFolderSelector(picker: picker, fileSystem: fileSystem, folderBrowser: folderBrowser)
        
        return try folderSelector.selectProjectFolder(path: path, group: group, fromDesktop: fromDesktop)
    }
    
    func selectProjectInfo(folder: Directory, shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> ProjectInfo {
        let infoSelector = ProjectInfoSelector(shell: shell, picker: picker, infoLoader: infoLoader)
        
        return try infoSelector.selectProjectInfo(folder: folder, shortcut: shortcut, group: group, isMainProject: isMainProject)
    }
    
    func getProjectToDelete(name: String?, shortcut: String?) throws -> LaunchProject {
        let projects = try projectService.loadProjects()
        let prompt = "Select the Project you would like to remove."
        // TODO: - update when evict is enabled
//        let prompt = "Select the Project you would like to remove. (Note: this will unregister the project from quick-launch. If you want to remove the project and keep it available for quick launch, use \("evict".bold)"
        
        if let name {
            if let project = projects.first(where: { $0.name.lowercased().contains(name.lowercased()) }) {
                return project
            }
            
            print("Cannot find project named \(name)")
        } else if let shortcut {
            if let project = projects.first(where: { shortcut.matches($0.shortcut) }) {
                return project
            }
        }
        
        return try picker.requiredSingleSelection(prompt, items: projects, showSelectedItemText: false)
    }
    
    func moveFolderIfNecessary(_ folder: Directory, parentPath: String?) throws {
        guard let parentPath else {
            throw CodeLaunchError.missingGroup
        }

        try projectService.moveProjectFolderIfNecessary(folder, parentPath: parentPath)
    }
    
    func saveProject(_ project: LaunchProject, in group: LaunchGroup, isMainProject: Bool) throws {
        try projectService.saveProject(project, in: group, isMainProject: isMainProject)
    }
    
    func deleteProject(_ project: LaunchProject) throws {
        if let group = try groupSelector.getProjectGroup(project: project) {
            if group.projects.count == 1 {
                try projectService.deleteProject(project, group: group, newMain: nil, useGroupShortcutForNewMain: false)
            } else {
                if let groupShortcut = group.shortcut, groupShortcut == project.shortcut {
                    let newMain = try selectNewMainProject(for: group, projectToDelete: project)
                    let useGroupShortcut = try shouldUpdateGroupShortcut(group: group, project: newMain)
                    
                    try projectService.deleteProject(
                        project,
                        group: group,
                        newMain: newMain,
                        useGroupShortcutForNewMain: useGroupShortcut
                    )
                } else {
                    try projectService.deleteProject(project, group: group, newMain: nil, useGroupShortcutForNewMain: false)
                }
            }
        } else {
            try projectService.deleteProject(project, group: nil, newMain: nil, useGroupShortcutForNewMain: false)
        }
    }
    
    func selectNewMainProject(for group: LaunchGroup, projectToDelete: LaunchProject) throws -> LaunchProject {
        let prompt = """
        \(projectToDelete.name) is the main project of \(group.name).
        Please select another project to be the new MAIN project for \(group.name).
        (NOTE: Groups are assigned the same shortcut as their main project.)
        """
        return try picker.requiredSingleSelection(prompt, items: group.projects.filter({ !$0.name.matches(projectToDelete.name) }), showSelectedItemText: false)
    }
    
    func shouldUpdateGroupShortcut(group: LaunchGroup, project: LaunchProject) throws -> Bool {
        let prompt = "Which shortcut would you like to use for the main project and group?"
        let updateGroup = "\(group.shortcut!)"
        let updateProject = "\(project.shortcut!)"
        let options: [String] = [updateGroup, updateProject]
        let selection = try picker.requiredSingleSelection(prompt, items: options, showSelectedItemText: false)

        return selection == updateGroup
    }
}


// MARK: - Extension Dependencies
private extension LaunchProject {
    init(info: ProjectInfo, type: ProjectType) {
        self.init(name: info.name, shortcut: info.shortcut, type: type, remote: info.remote, links: info.otherLinks)
    }
}
