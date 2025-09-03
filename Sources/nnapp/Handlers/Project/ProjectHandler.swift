//
//  ProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import Files
import Foundation
import SwiftPicker
import GitShellKit

/// Handles creation, removal, and eviction of `LaunchProject` objects.
/// Coordinates folder movement, Git inspection, and persistence updates.
struct ProjectHandler {
    private let shell: Shell
    private let picker: CommandLinePicker
    private let context: CodeLaunchContext
    private let gitShell: GitShellAdapter
    private let groupSelector: ProjectGroupSelector
    private let desktopPath: String?
    
    /// Initializes a new handler for managing projects.
    /// - Parameters:
    ///   - shell: Used for executing Git and terminal commands.
    ///   - picker: User-facing prompt utility.
    ///   - context: SwiftData-backed persistence layer.
    ///   - groupSelector: Logic for resolving a group during project creation.
    ///   - desktopPath: Optional custom desktop path for testing purposes.
    init(shell: Shell, picker: CommandLinePicker, context: CodeLaunchContext, groupSelector: ProjectGroupSelector, desktopPath: String? = nil) {
        self.shell = shell
        self.picker = picker
        self.context = context
        self.gitShell = .init(shell: shell)
        self.groupSelector = groupSelector
        self.desktopPath = desktopPath
    }
}


// MARK: - Add
extension ProjectHandler {
    /// Creates and registers a new `LaunchProject`, optionally syncing the group shortcut.
    /// - Parameters:
    ///   - path: Optional path to the project folder.
    ///   - group: Optional name of the group to assign the project to.
    ///   - shortcut: Optional quick-launch shortcut.
    ///   - isMainProject: Whether this is the main project for the group (used for terminal launches).
    ///   - fromDesktop: Whether to filter and select from valid projects on the Desktop.
    func addProject(path: String?, group: String?, shortcut: String?, isMainProject: Bool, fromDesktop: Bool) throws {
        let selectedGroup = try groupSelector.getGroup(named: group)
        let projectFolder = try selectProjectFolder(path: path, group: selectedGroup, fromDesktop: fromDesktop)
        let info = try selectProjectInfo(folder: projectFolder.folder, shortcut: shortcut, group: selectedGroup, isMainProject: isMainProject)
        let project = LaunchProject(name: info.name, shortcut: info.shortcut, type: projectFolder.type, remote: info.remote, links: info.otherLinks)
        
        if isMainProject || (selectedGroup.shortcut == nil && picker.getPermission("Is this the main project of \(selectedGroup.name)?")) {
            selectedGroup.shortcut = info.shortcut
        }
        
        try moveFolderIfNecessary(projectFolder.folder, parentPath: selectedGroup.path)
        try context.saveProject(project, in: selectedGroup)
    }
}


// MARK: - Remove
extension ProjectHandler {
    /// Unregisters a project from the database (does not delete local files).
    /// - Parameters:
    ///   - name: Optional name of the project.
    ///   - shortcut: Optional shortcut of the project.
    func removeProject(name: String?, shortcut: String?) throws {
        let projectToDelete = try getProject(name: name, shortcut: shortcut, selectionPrompt: "Select the Project you would like to remove. (Note: this will unregister the project from quick-launch. If you want to remove the project and keep it available for quick launch, use \("evict".bold)")
        
        // TODO: - maybe indicate that this is different from evicting?
        try picker.requiredPermission("Are you sure want to remove \(projectToDelete.name.yellow)?")
        try context.deleteProject(projectToDelete)
    }
}


// MARK: - Private Methods
private extension ProjectHandler {
    func selectProjectFolder(path: String?, group: LaunchGroup, fromDesktop: Bool) throws -> ProjectFolder {
        let folderSelector = ProjectFolderSelector(picker: picker, desktopPath: desktopPath)
        
        return try folderSelector.selectProjectFolder(path: path, group: group, fromDesktop: fromDesktop)
    }
    
    func selectProjectInfo(folder: Folder, shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> ProjectInfo {
        let infoSelector = ProjectInfoSelector(picker: picker, gitShell: gitShell, context: context)
        
        return try infoSelector.selectProjectInfo(folder: folder, shortcut: shortcut, group: group, isMainProject: isMainProject)
    }
    
    /// Moves a folder into the group folder if not already present.
    func moveFolderIfNecessary(_ folder: Folder, parentPath: String?) throws {
        guard let parentPath else {
            throw CodeLaunchError.missingGroup
        }
        
        let parentFolder = try Folder(path: parentPath)
        
        if let existingSubfolder = try? parentFolder.subfolder(named: folder.name) {
            if existingSubfolder.path != folder.path  {
                throw CodeLaunchError.folderNameTaken
            }
            
            print("Folder is already in correct location")
            return
        }
        
        try folder.move(to: parentFolder)
    }
}


// MARK: - Dependencies
protocol ProjectGroupSelector {
    func getGroup(named name: String?) throws -> LaunchGroup
}


// TODO: - will enable Evict soon
extension ProjectHandler {
    func evictProject(name: String?, shortcut: String?) throws {
        let projectToEvict = try getProject(name: name, shortcut: shortcut, selectionPrompt: "Select the Project you would like to evict")
        
        guard let folderPath = projectToEvict.folderPath, let folder = try? Folder(path: folderPath) else {
            print("Unable to locate the folder folder for \(projectToEvict.name).")
            throw CodeLaunchError.missingProject
        }
        
        try trashFolder(folder)
    }
    
    private func getProject(name: String?, shortcut: String?, selectionPrompt: String) throws -> LaunchProject {
        let projects = try context.loadProjects()
        
        if let name {
            if let project = projects.first(where: { $0.name.contains(name) }) {
                return project
            }
            
            print("Cannot find project named \(name)")
        } else if let shortcut {
            if let project = projects.first(where: { shortcut.matches($0.shortcut) }) {
                return project
            }
            
            print("Cannot find project with shortcut \(shortcut)")
        }
        
        return try picker.requiredSingleSelection(selectionPrompt, items: projects)
    }
}


// MARK: - Trash
private extension ProjectHandler {
    func trashFolder(_ folder: Folder) throws {
        let branches = try loadLocalBranches(folder: folder)
        
        // check for main branch
        if let currentBranch = branches.first(where: { $0.isCurrent }), !currentBranch.isMain {
            // TODO: -
            print("not on main branch")
        }
        
        // check for unmerged branches
        let unmergedBranches = branches.filter({ !$0.isMerged && !$0.isMain })
        if !unmergedBranches.isEmpty {
            print("unmerged branches")
            // TODO: -
//            errors.append(.unmergedBranches(unmergedBranches))
        }
        
        // checkfor branches ahead of remote
        let branchesWithUnsavedChanges = branches.filter({ $0.isAheadOfRemote })
        if !branchesWithUnsavedChanges.isEmpty {
            print("unsaved branches")
            // TODO: -
//            errors.append(.branchesWithUnsavedChanges(branchesWithUnsavedChanges))
        }
        
        // TODO: - delete project folder
        print("should delete \(folder.name) from \(folder.path)")
    }
    
    func loadLocalBranches(folder: Folder) throws -> [BranchInfo] {
        guard try gitShell.localGitExists(at: folder.path), try gitShell.remoteExists(path: folder.path) else {
            // TODO: -
            print("\(folder.name) has not been backed up with git and/or a remote repostory. If you want to evict it, do it yourself.")
            throw CodeLaunchError.missingGitRepository
        }
        
        let branchNames = try shell.run(makeGitCommand(.listLocalBranches, path: folder.path))
            .split(separator: "\n")
            .map({ $0.trimmingCharacters(in: .whitespaces) })
        
        let mergedOutput = try shell.run(makeGitCommand(.listMergedBranches(branchName: "main"), path: folder.path))
        let mergedBranches = Set(mergedOutput.split(separator: "\n").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }))
        
        return try branchNames.map { branchName in
            let isCurrentBranch = branchName.hasPrefix("*")
            let cleanBranchName = isCurrentBranch ? String(branchName.dropFirst(2)) : branchName
            let isMerged = cleanBranchName == "main" ? true : mergedBranches.contains(cleanBranchName)
            let syncStatus = try getSyncStatus(for: cleanBranchName, at: folder.path)
            
            return .init(name: cleanBranchName, isMerged: isMerged, isCurrent: isCurrentBranch, isAheadOfRemote: syncStatus == .ahead)
        }
    }
    
    func getSyncStatus(for branch: String, comparingBranch: String? = nil, at path: String) throws -> BranchSyncStatus {
        let remoteBranch = "origin/\(comparingBranch ?? branch)"
        let comparisonResult = try shell.run(makeGitCommand(.compareBranchAndRemote(local: branch, remote: remoteBranch), path: path)).trimmingCharacters(in: .whitespacesAndNewlines)
        let changes = comparisonResult.split(separator: "\t").map(String.init)
        
        guard changes.count == 2 else {
            return .undetermined
        }
        
        let ahead = changes[0]
        let behind = changes[1]
        
        if ahead == "0" && behind == "0" {
            return .nsync
        } else if ahead != "0" && behind == "0" {
            return .ahead
        } else if ahead == "0" && behind != "0" {
            return .behind
        } else {
            return .diverged
        }
    }
}


// MARK: - Dependencies
enum BranchSyncStatus: String, CaseIterable {
    case behind, ahead, nsync, diverged, undetermined, noRemoteBranch
}
