//
//  GroupManager.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public struct GroupManager: GroupService {
    private let store: any LaunchGroupStore
    private let fileSystem: any FileSystem

    public init(store: any LaunchGroupStore, fileSystem: any FileSystem) {
        self.store = store
        self.fileSystem = fileSystem
    }
}


// MARK: - Actions
public extension GroupManager {
    func loadGroups() throws -> [LaunchGroup] {
        return try store.loadGroups()
    }

    @discardableResult
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory, groupFolder: Directory?, categoryFolder: Directory?) throws -> LaunchGroup {
        let targetCategoryFolder = try categoryFolder ?? fileSystem.directory(at: category.path)

        if let groupFolder {
            try moveFolderIfNecessary(groupFolder, categoryFolder: targetCategoryFolder)
        } else {
            try createNewGroupFolder(group: group, categoryFolder: targetCategoryFolder)
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

    func deleteGroup(_ group: LaunchGroup) throws {
        try store.deleteGroup(group)
    }

    func projectGroup(for project: LaunchProject) throws -> LaunchGroup? {
        return try loadGroups().first(where: { group in
            group.projects.contains(where: { $0.name.matches(project.name) })
        })
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

    func shouldClearPreviousShortcut(group: LaunchGroup, shortcutToUse: String) -> Bool {
        guard let currentGroupShortcut = group.shortcut else {
            return false
        }

        return currentGroupShortcut.matches(shortcutToUse)
    }

    func persistMainProjectChange(group: LaunchGroup, currentMain: LaunchProject?, newMain: LaunchProject, shortcut: String) throws {
        if let currentMain, shouldClearPreviousShortcut(group: group, shortcutToUse: shortcut) {
            var clearedProject = currentMain
            clearedProject.shortcut = nil
            try store.updateProject(clearedProject)
        }

        var updatedGroup = group
        var updatedMain = newMain

        updatedGroup.shortcut = shortcut
        updatedMain.shortcut = shortcut

        try store.updateProject(updatedMain)
        try store.updateGroup(updatedGroup)
    }
}


// MARK: - Private Helpers
private extension GroupManager {
    func moveFolderIfNecessary(_ folder: Directory, categoryFolder: Directory) throws {
        if let existingFolder = categoryFolder.subdirectories.first(where: { $0.name.matches(folder.name) }) {
            if existingFolder.path != folder.path {
                throw CodeLaunchError.groupFolderAlreadyExists
            }

            return
        }

        try folder.move(to: categoryFolder)
    }

    func createNewGroupFolder(group: LaunchGroup, categoryFolder: Directory) throws {
        let subfolderNames = categoryFolder.subdirectories.map({ $0.name })

        if subfolderNames.contains(where: { $0.matches(group.name) }) {
            throw CodeLaunchError.groupFolderAlreadyExists
        }

        _ = try categoryFolder.createSubdirectory(named: group.name)
    }
}
