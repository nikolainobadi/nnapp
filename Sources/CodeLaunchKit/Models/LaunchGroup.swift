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
    
    public init(name: String, shortcut: String? = nil, projects: [LaunchProject]) {
        self.name = name
        self.shortcut = shortcut
        self.projects = projects
    }
}
