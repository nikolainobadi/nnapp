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

struct ProjectHandler {
    private let shell: Shell
    private let picker: Picker
    private let store: GroupHandler
    private let context: CodeLaunchContext
    private let gitShell: GitShellAdapter
    
    init(shell: Shell, picker: Picker, context: CodeLaunchContext) {
        self.shell = shell
        self.picker = picker
        self.context = context
        self.gitShell = .init(shell: shell)
        self.store = GroupHandler(picker: picker, context: context)
    }
}


// MARK: - Add
extension ProjectHandler {
    func addProject(path: String?, group: String?, shortcut: String?, isMainProject: Bool) throws {
        let selectedGroup = try store.getGroup(named: group)
        let projectFolder = try selectProjectFolder(path: path, group: selectedGroup)
        let shortcut = try getShortcut(shortcut: shortcut, group: selectedGroup, isMainProject: isMainProject)
        let remote = getRemote(folder: projectFolder.folder)
        let otherLinks = getOtherLinks()
        let project = LaunchProject(name: projectFolder.name, shortcut: shortcut, type: projectFolder.type, remote: remote, links: otherLinks)
        
        if isMainProject || (selectedGroup.shortcut == nil && picker.getPermission("Is this the main project of \(selectedGroup.name)?")) {
            selectedGroup.shortcut = shortcut
        }
        
        try context.saveProject(project, in: selectedGroup)
    }
}


// MARK: - Remove
extension ProjectHandler {
    func removeProject(name: String?, shortcut: String?) throws {
        let projectToDelete = try getProject(name: name, shortcut: shortcut, selectionPrompt: "Select the Project you would like to remove")
        
        // TODO: - maybe indicate that this is different from evicting?
        try picker.requiredPermission("Are you sure want to remove \(projectToDelete.name.yellow)?")
        try context.deleteProject(projectToDelete)
    }
}


// MARK: - Evict
extension ProjectHandler {
    func evictProject(name: String?, shortcut: String?) throws {
        let projectToEvict = try getProject(name: name, shortcut: shortcut, selectionPrompt: "Select the Project you would like to evict")
        
        guard let folderPath = projectToEvict.folderPath, let folder = try? Folder(path: folderPath) else {
            print("Unable to locate the folder folder for \(projectToEvict.name).")
            throw CodeLaunchError.missingProject
        }
        
        try trashFolder(folder)
    }
}


// MARK: - Private Methods
private extension ProjectHandler {
    // TODO: - need to verify that project name is available
    func selectProjectFolder(path: String?, group: LaunchGroup) throws -> ProjectFolder {
        if let path, let folder = try? Folder(path: path) {
            let projectType = try getProjectType(folder: folder)
            
            return .init(folder: folder, type: projectType)
        }
        
        guard let groupPath = group.path else {
            print("unable to resolve local path for \(group.name)")
            throw CodeLaunchError.missingGroup
        }
        
        let groupFolder = try Folder(path: groupPath)
        let availableFolders = getAvailableSubfolders(group: group, folder: groupFolder)
        
        if !availableFolders.isEmpty, picker.getPermission("Would you like to select a project from the \(groupFolder.name) folder?") {
            return try picker.requiredSingleSelection("Select a folder", items: availableFolders)
        }
        
        let path = try picker.getRequiredInput("Enter the path to the folder you want to use.")
        let folder = try Folder(path: path)
        let projectType = try getProjectType(folder: folder)
        
        return .init(folder: folder, type: projectType)
    }
    
    // TODO: - need to verify that project shortcut is available
    func getShortcut(shortcut: String?, group: LaunchGroup, isMainProject: Bool) throws -> String? {
        if let shortcut {
            return shortcut
        }
        
        let prompt = "Enter the shortcut to launch this project."
        
        if group.shortcut != nil && !isMainProject {
            guard picker.getPermission("Would you like to add a quick-launch shortcut for this project?") else {
                return nil
            }
        }
        
        return try picker.getRequiredInput(prompt)
    }
    
    func getAvailableSubfolders(group: LaunchGroup, folder: Folder) -> [ProjectFolder] {
        return folder.subfolders.compactMap { subFolder in
            guard !group.projects.map({ $0.name.lowercased() }).contains(subFolder.name.lowercased()), let projectType = try? getProjectType(folder: subFolder) else {
                return nil
            }
            
            return .init(folder: subFolder, type: projectType)
        }
    }
    
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
    
    func getRemote(folder: Folder) -> ProjectLink? {
        guard let githubURL = try? GitShellAdapter(shell: shell).getGitHubURL(at: folder.path), picker.getPermission("Is this the correct remote url: \(githubURL)?") else {
            return nil
        }
        
        // TODO: - will need to expand support for other websites
        return .init(name: "GitHub", urlString: githubURL)
    }
    
    func getOtherLinks() -> [ProjectLink] {
        return [] // TODO: -
    }
    
    func getProject(name: String?, shortcut: String?, selectionPrompt: String) throws -> LaunchProject {
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


// MARK: - Dependencies
struct ProjectFolder {
    let folder: Folder
    let type: ProjectType
    
    var name: String {
        return folder.name
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
        
        let mergedOutput = try shell.run(makeGitCommand(.listMergedBranches, path: folder.path))
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
struct BranchInfo {
    let name: String
    let isMerged: Bool
    let isCurrent: Bool
    let isAheadOfRemote: Bool
    
    var isMain: Bool {
        return name == "main"
    }
}

enum BranchSyncStatus: String, CaseIterable {
    case behind, ahead, nsync, diverged, undetermined, noRemoteBranch
}
