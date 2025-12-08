//
//  ProjectService.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public struct ProjectFolderCandidate {
    public let folder: Directory
    public let type: ProjectType

    public init(folder: Directory, type: ProjectType) {
        self.folder = folder
        self.type = type
    }
}

public protocol ProjectService {
    func loadProjects() throws -> [LaunchProject]
    func loadGroups() throws -> [LaunchGroup]
    func loadProjectLinkNames() -> [String]
    func validateName(_ name: String, projects: [LaunchProject]) throws -> String
    func validateShortcut(_ shortcut: String?, groups: [LaunchGroup], projects: [LaunchProject]) throws -> String?
    func moveProjectFolderIfNecessary(_ folder: Directory, parentPath: String) throws
    func saveProject(_ project: LaunchProject, in group: LaunchGroup, isMainProject: Bool) throws
    func deleteProject(_ project: LaunchProject, group: LaunchGroup?, newMain: LaunchProject?, useGroupShortcutForNewMain: Bool) throws
    func projectType(for folder: Directory) throws -> ProjectType
    func availableProjectFolders(group: LaunchGroup, categoryFolder: Directory) -> [ProjectFolderCandidate]
    func desktopProjectFolders(desktop: Directory) -> [ProjectFolderCandidate]
    func makeLink(name: String, urlString: String) -> ProjectLink?
    func append(_ link: ProjectLink?, to links: [ProjectLink]) -> [ProjectLink]
}
