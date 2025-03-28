//
//  NnappError.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

enum CodeLaunchError: Error {
    case missingGroup
    case missingProject
    case missingCategory
    case noProjectInFolder
    case noRemoteRepository
    case missingGitRepository
}
