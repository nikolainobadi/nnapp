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

    func loadProjectLinkNames() -> [String] {
        return store.loadProjectLinkNames()
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

        if updatedGroup.shortcut != group.shortcut {
            try store.updateGroup(updatedGroup)
        }
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

    func projectType(for folder: Directory) throws -> ProjectType {
        if folder.containsFile(named: "Package.swift") {
            return .package
        }

        if folder.subdirectories.contains(where: { $0.extension == "xcodeproj" }) {
            return .project
        }

        throw CodeLaunchError.noProjectInFolder
    }

    func availableProjectFolders(group: LaunchGroup, categoryFolder: Directory) -> [ProjectFolderCandidate] {
        return categoryFolder.subdirectories.compactMap { subFolder in
            guard
                !group.projects.map({ $0.name.lowercased() }).contains(subFolder.name.lowercased()),
                let projectType = try? projectType(for: subFolder)
            else {
                return nil
            }

            return .init(folder: subFolder, type: projectType)
        }
    }

    func desktopProjectFolders(desktop: Directory) -> [ProjectFolderCandidate] {
        return desktop.subdirectories.compactMap { subFolder in
            guard let projectType = try? projectType(for: subFolder) else {
                return nil
            }

            return .init(folder: subFolder, type: projectType)
        }
    }

    func makeLink(name: String, urlString: String) -> ProjectLink? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedURL.isEmpty else {
            return nil
        }

        return .init(name: trimmedName, urlString: trimmedURL)
    }

    func append(_ link: ProjectLink?, to links: [ProjectLink]) -> [ProjectLink] {
        guard let link else { return links }
        return links + [link]
    }
}
