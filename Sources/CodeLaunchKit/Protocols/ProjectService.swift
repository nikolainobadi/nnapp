//
//  ProjectService.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol ProjectService {
    func loadProjects() throws -> [LaunchProject]
    func loadGroups() throws -> [LaunchGroup]
    func validateName(_ name: String, projects: [LaunchProject]) throws -> String
    func validateShortcut(_ shortcut: String?, groups: [LaunchGroup], projects: [LaunchProject]) throws -> String?
    func moveProjectFolderIfNecessary(_ folder: Directory, parentPath: String) throws
    func saveProject(_ project: LaunchProject, in group: LaunchGroup, isMainProject: Bool) throws
    func deleteProject(_ project: LaunchProject, group: LaunchGroup?, newMain: LaunchProject?, useGroupShortcutForNewMain: Bool) throws
}
