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
        folderBrowser: any DirectoryBrowser
    ) {
        self.picker = picker
        self.fileSystem = fileSystem
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
            let projectType = try getProjectType(folder: directory)
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

        if !availableFolders.isEmpty,
           picker.getPermission("Would you like to select a project from the \(groupFolder.name) folder?") {
            return try picker.requiredSingleSelection("Select a folder", items: availableFolders)
        }

        let folder = try folderBrowser.browseForDirectory(
            prompt: "Browse to select a folder to use for your Project",
            startPath: groupPath
        )
        let projectType = try getProjectType(folder: folder)

        return .init(folder: folder, type: projectType)
    }
}


// MARK: - Private Methods
private extension ProjectFolderSelector {
    func getProjectType(folder: Directory) throws -> ProjectType {
        if folder.containsFile(named: "Package.swift") {
            return .package
        }

        if folder.subdirectories.contains(where: { $0.extension == "xcodeproj" }) {
            return .project
        }

        // TODO: - will need to also check for a workspace, then ask the user to choose which to use
        throw CodeLaunchError.noProjectInFolder
    }

    func getAvailableSubfolders(group: LaunchGroup, folder: Directory) -> [ProjectFolder] {
        return folder.subdirectories.compactMap { subFolder in
            guard !group.projects.map({ $0.name.lowercased() }).contains(subFolder.name.lowercased()),
                  let projectType = try? getProjectType(folder: subFolder) else {
                return nil
            }

            return .init(folder: subFolder, type: projectType)
        }
    }
    
    func getDesktopProjectFolders() throws -> [ProjectFolder] {
        let desktopFolder = try fileSystem.desktopDirectory()
        
        return desktopFolder.subdirectories.compactMap { subFolder in
            // Only include folders that contain valid Xcode projects or Swift packages
            guard let projectType = try? getProjectType(folder: subFolder) else {
                return nil
            }
            
            return .init(folder: subFolder, type: projectType)
        }
    }
}
