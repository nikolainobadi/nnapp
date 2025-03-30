//
//  BranchInfo.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

struct BranchInfo {
    let name: String
    let isMerged: Bool
    let isCurrent: Bool
    let isAheadOfRemote: Bool
    
    var isMain: Bool {
        return name == "main"
    }
}
