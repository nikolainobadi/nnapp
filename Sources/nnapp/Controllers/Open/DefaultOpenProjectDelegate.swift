//
//  DefaultOpenProjectDelegate.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import CodeLaunchKit

struct DefaultOpenProjectDelegate {
    private let ideLauncher: IDEHandler
    private let terminalManager: TerminalHandler
    private let urlLauncher: URLHandler
    private let branchSyncChecker: BranchSyncChecker
    private let branchStatusNotifier: BranchStatusNotifier
    
    init(
        shell: any LaunchGitShell,
        picker: any LaunchPicker,
        loader: any LaunchController.Loader,
        fileSystem: any FileSystem,
        environment: any TerminalEnvironmentProviding
    ) {
        self.ideLauncher = .init(shell: shell, picker: picker, fileSystem: fileSystem)
        self.terminalManager = .init(shell: shell, loader: loader, environment: environment)
        self.urlLauncher = .init(shell: shell, picker: picker)
        self.branchSyncChecker = .init(shell: shell, fileSystem: fileSystem)
        self.branchStatusNotifier = .init(shell: shell)
    }
}


// MARK: - LaunchDelegate
extension DefaultOpenProjectDelegate: LaunchDelegate {
    func openIDE(_ project: LaunchProject, launchType: LaunchType) throws {
        try ideLauncher.openInIDE(project, launchType: launchType)
    }

    func openTerminal(folderPath: String, option: TerminalOption?) {
        terminalManager.openDirectoryInTerminal(folderPath: folderPath, terminalOption: option)
    }

    func checkBranchStatus(for project: LaunchProject) -> LaunchBranchStatus? {
        return branchSyncChecker.checkBranchSyncStatus(for: project)
    }

    func notifyBranchStatus(_ status: LaunchBranchStatus, for project: LaunchProject) {
        branchStatusNotifier.notify(status: status, for: project)
    }

    func openRemoteURL(for remote: ProjectLink?) throws {
        try urlLauncher.openRemoteURL(remote: remote)
    }

    func openProjectLink(_ links: [ProjectLink]) throws {
        try urlLauncher.openProjectLink(links: links)
    }
}
