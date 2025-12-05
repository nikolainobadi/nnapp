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
    
    private var category: Category?
    
    public init(name: String, shortcut: String?, projects: [LaunchProject]) {
        self.name = name
        self.shortcut = shortcut
        self.projects = projects
    }
}


// MARK: - Helpers
public extension LaunchGroup {
    var categoryName: String? {
        return category?.name
    }
    
    var path: String? {
        guard let category else {
            return nil
        }
        
        return category.path.appendingPathComponent(name)
    }
    
    static func new(name: String, shortcut: String? = nil, projects: [LaunchProject] = []) -> LaunchGroup {
        return .init(name: name, shortcut: shortcut, projects: projects)
    }
}


// MARK: - Dependencies
extension LaunchGroup {
    struct Category {
        let name: String
        let path: String
    }
}
