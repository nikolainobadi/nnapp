//
//  ProjectFolderSelector.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct ProjectFolderSelector {
    private let picker: any LaunchPicker
    private let fileSystem: any FileSystem
    private let projectService: any ProjectService
    private let folderBrowser: any DirectoryBrowser

    /// Initializes a new folder selector using the provided user input picker.
    /// - Parameters:
    ///   - picker: Utility for interactive user prompts.
    ///   - folderBrowser: Utility for browsing and selecting folders.
    ///   - fileSystem: File system abstraction used for folder resolution.
    ///   - desktopPath: Optional desktop path override for testing.
    init(
        picker: any LaunchPicker,
        fileSystem: any FileSystem,
        projectService: any ProjectService,
        folderBrowser: any DirectoryBrowser
    ) {
        self.picker = picker
        self.fileSystem = fileSystem
        self.projectService = projectService
        self.folderBrowser = folderBrowser
    }
}


// MARK: - Action
extension ProjectFolderSelector {
    /// Prompts the user to select a folder for a project and resolves its type.
    /// - Parameters:
    ///   - path: Optional absolute path to a project folder.
    ///   - group: The group the project will belong to (used for default folder lookup).
    ///   - fromDesktop: Whether to filter and select from valid projects on the Desktop.
    /// - Returns: A validated `ProjectFolder` containing the resolved folder and type.
    func selectProjectFolder(path: String?, group: LaunchGroup, fromDesktop: Bool = false) throws -> ProjectFolder {
        if let path, let directory = try? fileSystem.directory(at: path) {
            let projectType = try projectService.projectType(for: directory)
            
            return .init(folder: directory, type: projectType)
        }
        
        if fromDesktop {
            let desktopFolders = try getDesktopProjectFolders()
            
            guard !desktopFolders.isEmpty else {
                print("No valid Xcode projects or Swift packages found on Desktop")
                throw CodeLaunchError.noProjectInFolder
            }
            
            return try picker.requiredSingleSelection("Select a project from Desktop", items: desktopFolders)
        }

        guard let groupPath = group.path else {
            print("unable to resolve local path for \(group.name)")
            throw CodeLaunchError.missingGroup
        }

        let groupFolder = try fileSystem.directory(at: groupPath)
        let availableFolders = getAvailableSubfolders(group: group, folder: groupFolder)
        let permissionPrompt = "Would you like to select a project from the \(groupFolder.name) folder?"

        if !availableFolders.isEmpty, picker.getPermission(permissionPrompt) {
            return try picker.requiredSingleSelection("Select a folder", items: availableFolders)
        }

        let browsePrompt = "Browse to select a folder to use for your Project"
        let folder = try folderBrowser.browseForDirectory(prompt: browsePrompt)
        let projectType = try projectService.projectType(for: folder)

        return .init(folder: folder, type: projectType)
    }
}


// MARK: - Private Methods
private extension ProjectFolderSelector {
    func getAvailableSubfolders(group: LaunchGroup, folder: any Directory) -> [ProjectFolder] {
        let candidates = projectService.availableProjectFolders(group: group, categoryFolder: folder)
        return candidates.map { ProjectFolder(folder: $0.folder, type: $0.type) }
    }
    
    func getDesktopProjectFolders() throws -> [ProjectFolder] {
        let desktopFolder = try fileSystem.desktopDirectory()

        let candidates = projectService.desktopProjectFolders(desktop: desktopFolder)
        return candidates.map { ProjectFolder(folder: $0.folder, type: $0.type) }
    }
}
