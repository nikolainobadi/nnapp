//
//  FirstSchema.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

@preconcurrency import SwiftData

enum FirstSchema: VersionedSchema {
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        return [
            LaunchCategory.self,
            LaunchGroup.self,
            LaunchProject.self
        ]
    }
}


// MARK: - LaunchCategory
extension FirstSchema {
    @Model
    final class LaunchCategory {
        @Attribute(.unique) var name: String
        @Attribute(.unique) var path: String
        @Relationship(deleteRule: .cascade, inverse: \LaunchGroup.category) var groups: [LaunchGroup] = []
        
        init(name: String, path: String) {
            self.name = name
            self.path = path
        }
    }
}


// MARK: - LaunchGroup
extension FirstSchema {
    @Model
    final class LaunchGroup {
        @Attribute(.unique) var name: String
        @Relationship(deleteRule: .cascade, inverse: \LaunchProject.group) var projects: [LaunchProject] = []
        
        var shortcut: String?
        var category: LaunchCategory?
        
        init(name: String, shortcut: String? = nil) {
            self.name = name
            self.shortcut = shortcut
        }
    }
}


// MARK: - LaunchProject
extension FirstSchema {
    @Model
    final class LaunchProject {
        @Attribute(.unique) var name: String
        @Attribute(.unique) var shortcut: String?
        
        var type: ProjectType
        var remote: ProjectLink?
        var links: [ProjectLink]
        var group: LaunchGroup?
        
        init(name: String, shortcut: String? = nil, type: ProjectType, remote: ProjectLink? = nil, links: [ProjectLink]) {
            self.name = name
            self.shortcut = shortcut
            self.type = type
            self.remote = remote
            self.links = links
        }
    }
    
    enum ProjectType: Codable {
        case project
        case package
        case workspace
    }
    
    struct ProjectLink: Codable, Equatable {
        let name: String
        let urlString: String

        init(name: String, urlString: String) {
            self.name = name
            self.urlString = urlString
        }
    }
}
