//
//  NnappError.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

enum CodeLaunchError: Error {
    case invalidInput
    case missingGroup
    case missingProject
    case missingCategory
    case missingProjectLink
    case noProjectInFolder
    case noRemoteRepository
    case missingGitRepository
    case projectLinkNameTaken
    case projectNameTaken
    case groupNameTaken
    case categoryNameTaken
    case categoryPathTaken
    case groupFolderAlreadyExists
    case shortcutTaken
    case folderNameTaken
}

enum ShellError: Error {
    case commandFailed(command: String, error: String)
}
