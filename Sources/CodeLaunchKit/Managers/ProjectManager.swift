//
//  ProjectManager.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public struct ProjectManager: ProjectService {
    private let store: any ProjectStore
    private let fileSystem: any FileSystem

    public init(store: any ProjectStore, fileSystem: any FileSystem) {
        self.store = store
        self.fileSystem = fileSystem
    }
}


// MARK: - Actions
public extension ProjectManager {
    func loadProjects() throws -> [LaunchProject] {
        return try store.loadProjects()
    }

    func loadGroups() throws -> [LaunchGroup] {
        return try store.loadGroups()
    }

    func validateName(_ name: String, projects: [LaunchProject]) throws -> String {
        if projects.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.projectNameTaken
        }

        return name
    }

    func validateShortcut(_ shortcut: String?, groups: [LaunchGroup], projects: [LaunchProject]) throws -> String? {
        guard let shortcut else { return nil }

        let allShortcuts = groups.compactMap({ $0.shortcut }) + projects.compactMap({ $0.shortcut })

        if allShortcuts.contains(where: { $0.matches(shortcut) }) {
            throw CodeLaunchError.shortcutTaken
        }

        return shortcut
    }

    func moveProjectFolderIfNecessary(_ folder: Directory, parentPath: String) throws {
        let parentFolder = try fileSystem.directory(at: parentPath)

        if let existingSubfolder = try? parentFolder.subdirectory(named: folder.name) {
            if existingSubfolder.path != folder.path  {
                throw CodeLaunchError.folderNameTaken
            }

            return
        }

        try folder.move(to: parentFolder)
    }

    func saveProject(_ project: LaunchProject, in group: LaunchGroup, isMainProject: Bool) throws {
        var updatedGroup = group

        if isMainProject || group.shortcut == nil {
            updatedGroup.shortcut = project.shortcut
        }

        try store.saveProject(project, in: updatedGroup)
    }

    func deleteProject(_ project: LaunchProject, group: LaunchGroup?, newMain: LaunchProject?, useGroupShortcutForNewMain: Bool) throws {
        guard let group else {
            try store.deleteProject(project)
            return
        }

        if group.projects.count == 1 {
            try store.deleteGroup(group)
            return
        }

        guard let groupShortcut = group.shortcut, groupShortcut == project.shortcut else {
            try store.deleteProject(project)
            return
        }

        guard var newMain else {
            try store.deleteProject(project)
            return
        }

        try store.deleteProject(project)

        var updatedGroup = group

        if useGroupShortcutForNewMain {
            newMain.shortcut = groupShortcut
            try store.updateProject(newMain)
        } else if let newMainShortcut = newMain.shortcut {
            updatedGroup.shortcut = newMainShortcut
        }

        try store.updateGroup(updatedGroup)
    }
}
