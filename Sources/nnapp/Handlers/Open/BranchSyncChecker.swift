//
//  BranchSyncChecker.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import NnShellKit
import GitShellKit
import GitCommandGen

// MARK: - Default Implementation
struct DefaultBranchSyncChecker {
    private let shell: any Shell
    private let gitShell: GitShellAdapter
    
    init(shell: any Shell) {
        self.shell = shell
        self.gitShell = .init(shell: shell)
    }
}


// MARK: - BranchSyncChecker
extension DefaultBranchSyncChecker: BranchSyncChecker {
    func checkBranchSyncStatus(for project: LaunchProject) {
        // Skip if project doesn't have a remote
        guard project.remote != nil else {
            return
        }

        // Skip if project folder doesn't exist
        guard let folderPath = project.folderPath, let folder = try? Folder(path: folderPath) else {
            return
        }

        // Skip if Git repo doesn't exist or has no remote
        guard (try? gitShell.localGitExists(at: folder.path)) == true, (try? gitShell.remoteExists(path: folder.path)) == true else {
            return
        }

        // Get current branch name
        guard let currentBranch = try? shell.bash(makeGitCommand(.getCurrentBranchName, path: folder.path)).trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }

        // Check current branch sync status
        if let currentStatus = try? getSyncStatus(for: currentBranch, at: folder.path), (currentStatus == .behind || currentStatus == .diverged) {
            print("⚠️  Current branch '\(currentBranch)' is \(currentStatus.rawValue) the remote branch".yellow)
        }

        // Check main branch sync status if not already on main
        if currentBranch != "main" {
            if let mainStatus = try? getSyncStatus(for: "main", at: folder.path), (mainStatus == .behind || mainStatus == .diverged) {
                print("⚠️  Main branch is \(mainStatus.rawValue) the remote branch".yellow)
            }
        }
    }
}


// MARK: - Private Helpers
private extension DefaultBranchSyncChecker {
    /// Determines the sync status of a local branch compared to its remote counterpart.
    /// - Parameters:
    ///   - branch: The local branch name.
    ///   - path: The path to the Git repository.
    /// - Returns: The sync status of the branch.
    func getSyncStatus(for branch: String, at path: String) throws -> BranchSyncStatus {
        let remoteBranch = "origin/\(branch)"
        let comparisonResult = try shell.bash(makeGitCommand(.compareBranchAndRemote(local: branch, remote: remoteBranch), path: path)).trimmingCharacters(in: .whitespacesAndNewlines)
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
