//
//  CodeLaunchContext.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import SwiftData
import Foundation
import NnSwiftDataKit

public final class CodeLaunchContext {
    let context: ModelContext
    let defaults: UserDefaults
    
    public init() throws {
        let appGroupId = "R8SJ24LQF3.com.nobadi.codelaunch"
        let (config, defaults) = try configureSwiftDataContainer(appGroupId: appGroupId)
        let container = try ModelContainer(for: LaunchCategory.self, configurations: config)
        
        self.defaults = defaults
        self.context = .init(container)
    }
}

extension CodeLaunchContext {
    func loadCategories() throws -> [LaunchCategory] {
        return try load()
    }
    
    func loadGroups() throws -> [LaunchGroup] {
        return try load()
    }
}

extension CodeLaunchContext {
    func saveCatgory(_ category: LaunchCategory) throws {
        context.insert(category)
        try context.save()
    }
    
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory) throws {
        context.insert(group)
        group.category = category
        category.groups.append(group)
        
        try context.save()
    }
    
    func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
        context.insert(project)
        project.group = group
        group.projects.append(project)
        
        try context.save()
    }
}


// MARK: - Private Methods
private extension CodeLaunchContext {
    func load<Item: PersistentModel>() throws -> [Item] {
        return try context.fetch(FetchDescriptor<Item>())
    }
}



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

@Model
public final class LaunchGroup {
    @Attribute(.unique) public var name: String
    @Relationship(deleteRule: .cascade, inverse: \LaunchProject.group) public var projects: [LaunchProject] = []
    
    public var shortcut: String?
    public var category: LaunchCategory?
    
    public init(name: String) {
        self.name = name
    }
}

@Model
public final class LaunchProject {
    @Attribute(.unique) public var name: String
    @Attribute(.unique) public var shortcut: String?
    
    public var type: ProjectType
    public var remote: ProjectLink?
    public var links: [ProjectLink]
    public var group: LaunchGroup?
    
    public init(name: String, shortcut: String?, type: ProjectType, remote: ProjectLink?, links: [ProjectLink]) {
        self.name = name
        self.shortcut = shortcut
        self.type = type
        self.remote = remote
        self.links = links
    }
}

public enum ProjectType: Codable {
    case project, package, workspace
}

public struct ProjectLink: Codable, Equatable {
    public let name: String
    public let urlString: String
    
    public init(name: String, urlString: String) {
        self.name = name
        self.urlString = urlString
    }
}
