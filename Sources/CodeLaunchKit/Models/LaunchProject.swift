//
//  LaunchProject.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public struct LaunchProject {
    public var name: String
    public var shortcut: String?
    public var type: ProjectType
    public var remote: ProjectLink?
    public var links: [ProjectLink]
    
    public init(name: String, shortcut: String? , type: ProjectType, remote: ProjectLink?, links: [ProjectLink]) {
        self.name = name
        self.shortcut = shortcut
        self.type = type
        self.remote = remote
        self.links = links
    }
}


// MARK: - Dependencies
public enum ProjectType {
    case project, package, workspace
}

public struct ProjectLink: Equatable {
    public let name: String
    public let urlString: String
    
    public init(name: String, urlString: String) {
        self.name = name
        self.urlString = urlString
    }
}
