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
    public var category: Category?
    
    public var categoryName: String? {
        return category?.name
    }
    
    public var path: String? {
        guard let category else {
            return nil
        }
        
        return category.path.appendingPathComponent(name)
    }
    
    public init(name: String, shortcut: String?, projects: [LaunchProject], category: Category?) {
        self.name = name
        self.shortcut = shortcut
        self.projects = projects
        self.category = category
    }
}


// MARK: - Helpers
public extension LaunchGroup {
    static func new(name: String, shortcut: String? = nil, projects: [LaunchProject] = [], category: Category? = nil) -> LaunchGroup {
        return .init(name: name, shortcut: shortcut, projects: projects, category: category)
    }
}


// MARK: - Dependencies
extension LaunchGroup {
    public struct Category {
        let name: String
        let path: String
    }
}
