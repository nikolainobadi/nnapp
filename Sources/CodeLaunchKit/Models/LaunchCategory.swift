//
//  LaunchCategory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public struct LaunchCategory {
    public var name: String
    public var path: String
    public var groups: [LaunchGroup]
    
    public init(name: String, path: String, groups: [LaunchGroup]) {
        self.name = name
        self.path = path
        self.groups = groups
    }
}


// MARK: - Helpers
public extension LaunchCategory {
    static func new(name: String, path: String, groups: [LaunchGroup] = []) -> LaunchCategory {
        return .init(name: name, path: path, groups: groups)
    }
}
