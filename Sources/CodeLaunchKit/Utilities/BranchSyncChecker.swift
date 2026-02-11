//
//  BranchSyncChecker.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import GitCommandGen

public struct BranchSyncChecker {
    private let shell: any LaunchGitShell
    private let fileSystem: any FileSystem

    public init(shell: any LaunchGitShell, fileSystem: any FileSystem) {
        self.shell = shell
        self.fileSystem = fileSystem
    }
}


// MARK: - Evict Check
public extension BranchSyncChecker {
    func verifyCanEvict(_ project: LaunchProject) throws {
        guard let folderPath = project.folderPath, let folder = try? fileSystem.directory(at: folderPath) else {
            throw CodeLaunchError.missingProject
        }

        guard (try? shell.localGitExists(at: folder.path)) == true, (try? shell.remoteExists(path: folder.path)) == true else {
            throw CodeLaunchError.missingGitRepository
        }

        let localChanges = try? shell.bash(makeGitCommand(.getLocalChanges, path: folder.path)).trimmingCharacters(in: .whitespacesAndNewlines)

        if let localChanges, !localChanges.isEmpty {
            throw CodeLaunchError.dirtyWorkingTree
        }

        let _ = try? shell.runGitCommandWithOutput(.fetchOrigin, path: folder.path)

        guard let currentBranch = try? shell.bash(makeGitCommand(.getCurrentBranchName, path: folder.path)).trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw CodeLaunchError.missingGitRepository
        }

        let status = try getSyncStatus(for: currentBranch, at: folder.path)

        if status == .ahead || status == .diverged {
            throw CodeLaunchError.projectAheadOfRemote
        }
    }
}


// MARK: - BranchSyncChecker
public extension BranchSyncChecker {
    func checkBranchSyncStatus(for project: LaunchProject) -> LaunchBranchStatus? {
        // Skip if project doesn't have a remote
        guard project.remote != nil else {
            print("no remote")
            return nil
        }

        // Skip if project folder doesn't exist
        guard let folderPath = project.folderPath, let folder = try? fileSystem.directory(at: folderPath) else {
            print("could not find folder")
            return nil
        }

        // Skip if Git repo doesn't exist or has no remote
        guard (try? shell.localGitExists(at: folder.path)) == true, (try? shell.remoteExists(path: folder.path)) == true else {
            print("no local or remote repo")
            return nil
        }
        
        let originResult = try? shell.runGitCommandWithOutput(.fetchOrigin, path: folder.path)
        
        if originResult == nil {
            print("failed to fetch origin for \(project.name)")
            return nil
        }

        // Get current branch name
        guard let currentBranch = try? shell.bash(makeGitCommand(.getCurrentBranchName, path: folder.path)).trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("could not find current branch")
            return nil
        }

        // Check current branch sync status
        if let currentStatus = try? getSyncStatus(for: currentBranch, at: folder.path) {
            if currentStatus == .behind {
                return .behind
            } else if currentStatus == .diverged {
                return .diverged
            }
        } else {
            print("could not get sync status")
        }

        // Check main branch sync status if not already on main
        if currentBranch != "main" {
            if let mainStatus = try? getSyncStatus(for: "main", at: folder.path) {
                if mainStatus == .behind {
                    return .behind
                } else if mainStatus == .diverged {
                    return .diverged
                }
            }
        }

        return nil
    }
}


// MARK: - Private Helpers
private extension BranchSyncChecker {
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


// MARK: - Dependencies
enum BranchSyncStatus: String, CaseIterable {
    case behind, ahead, nsync, diverged, undetermined, noRemoteBranch
}
