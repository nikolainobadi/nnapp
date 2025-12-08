//
//  ProjectSupportService.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public struct ProjectFolderCandidate {
    public let folder: Directory
    public let type: ProjectType

    public init(folder: Directory, type: ProjectType) {
        self.folder = folder
        self.type = type
    }
}

public protocol ProjectSupportService {
    func projectType(for folder: Directory) throws -> ProjectType
    func availableProjectFolders(group: LaunchGroup, categoryFolder: Directory) -> [ProjectFolderCandidate]
    func desktopProjectFolders(desktop: Directory) -> [ProjectFolderCandidate]
    func makeLink(name: String, urlString: String) -> ProjectLink?
    func append(_ link: ProjectLink?, to links: [ProjectLink]) -> [ProjectLink]
}
