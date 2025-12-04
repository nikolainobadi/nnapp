//
//  FirstSchema.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

@preconcurrency import SwiftData

public enum FirstSchema: VersionedSchema {
    public static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    public static var models: [any PersistentModel.Type] {
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
    public final class LaunchCategory {
        @Attribute(.unique) public var name: String
        @Attribute(.unique) public var path: String
        @Relationship(deleteRule: .cascade, inverse: \LaunchGroup.category) public var groups: [LaunchGroup] = []
        
        public init(name: String, path: String) {
            self.name = name
            self.path = path
        }
    }
}


// MARK: - LaunchGroup
extension FirstSchema {
    @Model
    public final class LaunchGroup {
        @Attribute(.unique) public var name: String
        @Relationship(deleteRule: .cascade, inverse: \LaunchProject.group) public var projects: [LaunchProject] = []
        
        public var shortcut: String?
        public var category: LaunchCategory?
        
        public init(name: String, shortcut: String? = nil) {
            self.name = name
            self.shortcut = shortcut
        }
    }
}


// MARK: - LaunchProject
extension FirstSchema {
    @Model
    public final class LaunchProject {
        @Attribute(.unique) public var name: String
        @Attribute(.unique) public var shortcut: String?
        
        public var type: ProjectType
        public var remote: ProjectLink?
        public var links: [ProjectLink]
        public var group: LaunchGroup?
        
        public init(name: String, shortcut: String? = nil, type: ProjectType, remote: ProjectLink? = nil, links: [ProjectLink]) {
            self.name = name
            self.shortcut = shortcut
            self.type = type
            self.remote = remote
            self.links = links
        }
    }
    
    public enum ProjectType: Codable {
        case project
        case package
        case workspace
    }
    
    public struct ProjectLink: Codable, Equatable {
        public let name: String
        public let urlString: String

        public init(name: String, urlString: String) {
            self.name = name
            self.urlString = urlString
        }
    }
}
