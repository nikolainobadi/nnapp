//
//  BranchInfo.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

/// Represents metadata about a local Git branch used during project eviction checks.
struct BranchInfo {
    /// The branch name (e.g. `main`, `feature/foo`)
    let name: String
    
    /// Indicates whether the branch has been merged into the main branch.
    let isMerged: Bool
    
    /// Indicates whether this is the currently checked-out branch.
    let isCurrent: Bool

    /// Indicates whether this branch has commits ahead of its remote counterpart.
    let isAheadOfRemote: Bool

    /// Returns `true` if the branch is named `main`.
    var isMain: Bool {
        return name == "main"
    }
}
