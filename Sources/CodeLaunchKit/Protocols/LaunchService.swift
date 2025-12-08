//
//  LaunchService.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol LaunchService {
    func resolveProject(shortcut: String?, useGroupShortcut: Bool) throws -> LaunchProject
    func groupProjects(shortcut: String) throws -> [LaunchProject]
    func openInIDE(_ project: LaunchProject, launchType: LaunchType, terminalOption: TerminalOption?) throws
    func openRemoteURL(for project: LaunchProject) throws
    func openProjectLink(for project: LaunchProject) throws
}
