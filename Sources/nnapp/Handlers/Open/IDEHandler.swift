//
//  IDEHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import GitShellKit
import CodeLaunchKit

struct IDEHandler {
    private let shell: any LaunchShell
    private let picker: any LaunchPicker
    private let fileSystem: any FileSystem
    
    init(shell: any LaunchShell, picker: any LaunchPicker, fileSystem: any FileSystem) {
        self.shell = shell
        self.picker = picker
        self.fileSystem = fileSystem
    }
}


// MARK: - IDE Operations
extension IDEHandler {
    /// Opens the project in Xcode or VSCode.
    /// - Parameters:
    ///   - project: The project to open.
    ///   - launchType: Whether to open in Xcode or VSCode.
    func openInIDE(_ project: LaunchProject, launchType: LaunchType) throws {
        guard let folderPath = project.folderPath, let filePath = project.filePath else {
            throw CodeLaunchError.missingProject
        }
        
        try cloneProjectIfNecessary(project, folderPath: folderPath, filePath: filePath)
        
        let isXcode = launchType == .xcode
        try shell.runAndPrint(bash: "\(isXcode ? "open" : "code") \(isXcode ? filePath : folderPath)")
    }
}


// MARK: - Private Methods
private extension IDEHandler {
    /// Clones the project repo if it doesn't exist locally and a remote is available.
    func cloneProjectIfNecessary(_ project: LaunchProject, folderPath: String, filePath: String) throws {
        do {
            _ = try fileSystem.directory(at: folderPath) // already exists
        } catch {
            guard let remote = project.remote,
                  let groupPath = project.groupPath,
                  !groupPath.isEmpty
            else {
                print("cannot locate project \(project.name) and no remote repository exists")
                throw CodeLaunchError.noRemoteRepository
            }
            
            let prompt = """
            Unable to locate \(project.fileName.green) at path \(filePath.yellow)
            Would you like to fetch it from \(remote.name.green) - \(remote.urlString.yellow)?
            """
            
            try picker.requiredPermission(prompt)
            try shell.runAndPrint(bash: makeGitCommand(.clone(url: remote.urlString), path: groupPath))
        }
    }
}
