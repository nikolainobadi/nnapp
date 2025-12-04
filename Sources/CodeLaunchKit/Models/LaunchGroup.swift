//
//  LaunchGroup.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public struct LaunchGroup {
    public var name: String
    public var shortcut: String?
    public var projects: [LaunchProject]
    
    public init(name: String, shortcut: String?, projects: [LaunchProject]) {
        self.name = name
        self.shortcut = shortcut
        self.projects = projects
    }
}


// MARK: - Helpers
public extension LaunchGroup {
    static func new(name: String, shortcut: String? = nil, projects: [LaunchProject] = []) -> LaunchGroup {
        return .init(name: name, shortcut: shortcut, projects: projects)
    }
}
