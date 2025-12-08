//
//  LaunchDelegate.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol LaunchDelegate {
    func openIDE(_ project: LaunchProject, launchType: LaunchType) throws
    func openTerminal(folderPath: String, option: TerminalOption?)
    func checkBranchStatus(for project: LaunchProject) -> LaunchBranchStatus?
    func notifyBranchStatus(_ status: LaunchBranchStatus, for project: LaunchProject)
    func openRemoteURL(for remote: ProjectLink?) throws
    func openProjectLink(_ links: [ProjectLink]) throws
}
