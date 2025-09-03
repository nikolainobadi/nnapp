//
//  ProjectFolderSelector.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Files
import SwiftPicker

/// Handles selection and validation of project folders for use in `LaunchProject` creation.
/// Determines the `ProjectType` by inspecting folder contents.
struct ProjectFolderSelector {
    private let picker: CommandLinePicker

    /// Initializes a new folder selector using the provided user input picker.
    /// - Parameter picker: Utility for interactive user prompts.
    init(picker: CommandLinePicker) {
        self.picker = picker
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
        if let path, let folder = try? Folder(path: path) {
            let projectType = try getProjectType(folder: folder)
            return .init(folder: folder, type: projectType)
        }
        
        // Handle --from-desktop flag
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

        let groupFolder = try Folder(path: groupPath)
        let availableFolders = getAvailableSubfolders(group: group, folder: groupFolder)

        if !availableFolders.isEmpty,
           picker.getPermission("Would you like to select a project from the \(groupFolder.name) folder?") {
            return try picker.requiredSingleSelection("Select a folder", items: availableFolders)
        }

        let path = try picker.getRequiredInput("Enter the path to the folder you want to use.")
        let folder = try Folder(path: path)
        let projectType = try getProjectType(folder: folder)

        return .init(folder: folder, type: projectType)
    }
}


// MARK: - Private Methods
private extension ProjectFolderSelector {
    /// Determines the project type (e.g. package, project, workspace) by inspecting the folder contents.
    func getProjectType(folder: Folder) throws -> ProjectType {
        if folder.containsFile(named: "Package.swift") {
            return .package
        }

        if folder.subfolders.contains(where: { $0.extension == "xcodeproj" }) {
            return .project
        }

        // TODO: - will need to also check for a workspace, then ask the user to choose which to use
        throw CodeLaunchError.noProjectInFolder
    }

    /// Returns a list of valid project subfolders within the group folder that are not already registered.
    func getAvailableSubfolders(group: LaunchGroup, folder: Folder) -> [ProjectFolder] {
        return folder.subfolders.compactMap { subFolder in
            guard !group.projects.map({ $0.name.lowercased() }).contains(subFolder.name.lowercased()),
                  let projectType = try? getProjectType(folder: subFolder) else {
                return nil
            }

            return .init(folder: subFolder, type: projectType)
        }
    }
    
    /// Returns a list of valid Xcode projects and Swift packages from the user's Desktop.
    func getDesktopProjectFolders() throws -> [ProjectFolder] {
        let desktopPath = Folder.home.path.appendingPathComponent("Desktop")
        let desktopFolder = try Folder(path: desktopPath)
        
        return desktopFolder.subfolders.compactMap { subFolder in
            // Only include folders that contain valid Xcode projects or Swift packages
            guard let projectType = try? getProjectType(folder: subFolder) else {
                return nil
            }
            
            return .init(folder: subFolder, type: projectType)
        }
    }
}
