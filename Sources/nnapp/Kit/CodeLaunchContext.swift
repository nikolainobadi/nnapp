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
    private let launchScriptKey = "launchScriptKey"
    private let projectLinkNameListKey = "projectLinkNameListKey"
    
    let context: ModelContext
    let defaults: UserDefaults
    
    public init(config: ModelConfiguration? = nil, defaults: UserDefaults? = nil) throws {
        let appGroupId = "R8SJ24LQF3.com.nobadi.codelaunch"
        var userDefaults: UserDefaults
        var configuration: ModelConfiguration
        
        if let config, let defaults {
            configuration = config
            userDefaults = defaults
        } else {
            let (config, defaults) = try configureSwiftDataContainer(appGroupId: appGroupId)
            
            configuration = config
            userDefaults = defaults
        }
        
        let container = try ModelContainer(for: LaunchCategory.self, configurations: configuration)
        
        self.defaults = userDefaults
        self.context = .init(container)
    }
}


// MARK: - Load
extension CodeLaunchContext {
    func loadCategories() throws -> [LaunchCategory] {
        return try load()
    }
    
    func loadGroups() throws -> [LaunchGroup] {
        return try load()
    }
    
    func loadProjects() throws -> [LaunchProject] {
        return try load()
    }
    
    func loadProjectLinkNames() -> [String] {
        return defaults.array(forKey: projectLinkNameListKey) as? [String] ?? []
    }
    
    func loadLaunchScript() -> String? {
        guard let script = defaults.string(forKey: launchScriptKey), !script.isEmpty else {
            return nil
        }
        
        return script
    }
}


// MARK: - Save
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
    
    func saveProjectLinkNames(_ names: [String]) {
        defaults.set(names, forKey: projectLinkNameListKey)
    }
}


// MARK: - Delete
extension CodeLaunchContext {
    func deleteCategory(_ category: LaunchCategory) throws {
        for group in category.groups {
            try deleteGroup(group, skipSave: true)
        }
        
        context.delete(category)
        try context.save()
    }
    
    func deleteGroup(_ group: LaunchGroup, skipSave: Bool = false) throws {
        for project in group.projects {
            try deleteProject(project, skipSave: true)
        }
        
        context.delete(group)
        
        if !skipSave {
            try context.save()
        }
    }
    
    func deleteProject(_ project: LaunchProject, skipSave: Bool = false) throws {
        context.delete(project)
        
        if !skipSave {
            try context.save()
        }
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
    
    public init(name: String, shortcut: String? = nil) {
        self.name = name
        self.shortcut = shortcut
    }
}

public extension LaunchGroup {
    var path: String? {
        guard let category else {
            return nil
        }
        
        return category.path.appendingPathComponent(name)
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

public extension LaunchProject {
    var fileName: String {
        switch type {
        case .package:
            return "Package.swift"
        default:
            return "\(name).\(type.fileExtension)"
        }
    }
    
    var groupPath: String? {
        guard let group, let category = group.category else {
            return nil
        }
        
        return category.path.appendingPathComponent(group.name)
    }
    
    var folderPath: String? {
        guard let groupPath else {
            return nil
        }
        
        return groupPath.appendingPathComponent(name)
    }
    
    var filePath: String? {
        guard let folderPath else {
            return nil
        }
        
        return folderPath.appendingPathComponent(fileName)
    }
}

public enum ProjectType: Codable {
    case project, package, workspace
}

public extension ProjectType {
    var name: String {
        switch self {
        case .project:
            return "Xcode Project"
        case .package:
            return "Swift Package"
        case .workspace:
            return "XCWorkspace"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .project:
            return "xcodeproj"
        case .package:
            return "swift"
        case .workspace:
            return "xcworkspace"
        }
    }
}

public struct ProjectLink: Codable, Equatable {
    public let name: String
    public let urlString: String
    
    public init(name: String, urlString: String) {
        self.name = name
        self.urlString = urlString
    }
}


public extension String {
    func appendingPathComponent(_ path: String) -> String {
        let selfHasSlash = self.hasSuffix("/")
        let pathHasSlash = path.hasPrefix("/")
        
        if selfHasSlash && pathHasSlash {
            return self + String(path.dropFirst())
        } else if !selfHasSlash && !pathHasSlash {
            return self + "/" + path
        } else {
            return self + path
        }
    }
}
