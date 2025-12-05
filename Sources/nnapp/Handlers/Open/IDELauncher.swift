//
//  IDELauncher.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import Foundation
import NnShellKit
import GitShellKit
import CodeLaunchKit
import SwiftPickerKit

/// Handles launching projects in IDEs (Xcode/VSCode) and cloning repositories when needed.
struct IDELauncher {
    private let shell: any Shell
    private let picker: any CommandLinePicker
    
    /// Initializes a new IDE launcher.
    /// - Parameters:
    ///   - shell: Shell protocol for executing system commands.
    ///   - picker: Utility for prompting user input and permissions.
    init(shell: any Shell, picker: any CommandLinePicker) {
        self.shell = shell
        self.picker = picker
    }
}


// MARK: - IDE Operations
extension IDELauncher {
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
private extension IDELauncher {
    /// Clones the project repo if it doesn't exist locally and a remote is available.
    func cloneProjectIfNecessary(_ project: LaunchProject, folderPath: String, filePath: String) throws {
        do {
            _ = try Folder(path: folderPath) // already exists
        } catch {
            guard let remote = project.remote,
                  let groupPath = project.groupPath,
                  !groupPath.isEmpty
            else {
                print("cannot locate project \(project.name) and no remote repository exists")
                throw CodeLaunchError.noRemoteRepository
            }
            
            try picker.requiredPermission(prompt: """
            Unable to locate \(project.fileName.green) at path \(filePath.yellow)
            Would you like to fetch it from \(remote.name.green) - \(remote.urlString.yellow)?
            """)
            
            let cloneCommand = makeGitCommand(.clone(url: remote.urlString), path: groupPath)
            try shell.runAndPrint(bash: cloneCommand)
        }
    }
}
