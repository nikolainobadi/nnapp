//
//  CodeLaunchError.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public enum CodeLaunchError: Error {
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
