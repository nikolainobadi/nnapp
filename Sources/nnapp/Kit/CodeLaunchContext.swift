//
//  CodeLaunchContext.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import SwiftData
import Foundation
import NnSwiftDataKit

/// Manages loading, saving, and deleting Categories, Groups, and Projects from SwiftData and UserDefaults.
/// Acts as the primary interface to CodeLaunch's persistent state.
final class CodeLaunchContext {
    private let launchScriptKey = "launchScriptKey"
    private let projectLinkNameListKey = "projectLinkNameListKey"
    
    let context: ModelContext
    let defaults: UserDefaults
    
    /// Initializes the CodeLaunchContext using optional configuration and user defaults.
    /// If none are provided, a default SwiftData container is created for the app group.
    /// - Parameters:
    ///   - config: Optional SwiftData model configuration.
    ///   - defaults: Optional UserDefaults, typically injected for testing or previews.
    init(config: ModelConfiguration? = nil, defaults: UserDefaults? = nil) throws {
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
    /// Loads all saved launch categories from the SwiftData context.
    /// - Returns: An array of `LaunchCategory` objects.
    func loadCategories() throws -> [LaunchCategory] {
        return try load()
    }
    
    /// Loads all saved launch groups from the SwiftData context.
    /// - Returns: An array of `LaunchGroup` objects.
    func loadGroups() throws -> [LaunchGroup] {
        return try load()
    }
    
    /// Loads all saved launch projects from the SwiftData context.
    /// - Returns: An array of `LaunchProject` objects.
    func loadProjects() throws -> [LaunchProject] {
        return try load()
    }
    
    /// Retrieves the list of saved project link names from UserDefaults.
    /// - Returns: An array of link name strings, or an empty array if none exist.
    func loadProjectLinkNames() -> [String] {
        return defaults.array(forKey: projectLinkNameListKey) as? [String] ?? []
    }
    
    /// Retrieves the terminal launch script from UserDefaults, if set and non-empty.
    /// - Returns: The script as a string, or `nil` if not available.
    func loadLaunchScript() -> String? {
        guard let script = defaults.string(forKey: launchScriptKey), !script.isEmpty else {
            return nil
        }
        
        return script
    }
}


// MARK: - Save
extension CodeLaunchContext {
    /// Persists a new launch category to the SwiftData context.
    /// - Parameter category: The category to save.
    func saveCategory(_ category: LaunchCategory) throws {
        context.insert(category)
        try context.save()
    }
    
    /// Persists a new launch group under the specified category.
    /// - Parameters:
    ///   - group: The group to save.
    ///   - category: The parent category to associate with.
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory) throws {
        context.insert(group)
        group.category = category
        category.groups.append(group)
        
        try context.save()
    }
    
    /// Persists a new launch project under the specified group.
    /// - Parameters:
    ///   - project: The project to save.
    ///   - group: The parent group to associate with.
    func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
        context.insert(project)
        project.group = group
        group.projects.append(project)
        
        try context.save()
    }
    
    /// Saves a list of project link names to UserDefaults.
    /// - Parameter names: The list of names to save.
    func saveProjectLinkNames(_ names: [String]) {
        defaults.set(names, forKey: projectLinkNameListKey)
    }
}


// MARK: - Delete
extension CodeLaunchContext {
    /// Deletes a category and all associated groups and projects.
    /// - Parameter category: The category to delete.
    func deleteCategory(_ category: LaunchCategory) throws {
        for group in category.groups {
            try deleteGroup(group, skipSave: true)
        }
        
        context.delete(category)
        try context.save()
    }
    
    /// Deletes a group and its associated projects.
    /// - Parameters:
    ///   - group: The group to delete.
    ///   - skipSave: If true, defers saving the context (used when part of a batch operation).
    func deleteGroup(_ group: LaunchGroup, skipSave: Bool = false) throws {
        for project in group.projects {
            try deleteProject(project, skipSave: true)
        }
        
        context.delete(group)
        
        if !skipSave {
            try context.save()
        }
    }
    
    /// Deletes a single launch project from the SwiftData context.
    /// - Parameters:
    ///   - project: The project to delete.
    ///   - skipSave: If true, defers saving the context (used when part of a batch operation).
    func deleteProject(_ project: LaunchProject, skipSave: Bool = false) throws {
        context.delete(project)
        
        if !skipSave {
            try context.save()
        }
    }
}


// MARK: - Private Methods
private extension CodeLaunchContext {
    /// Generic fetch for any PersistentModel type from SwiftData context.
    /// - Returns: An array of loaded models of the specified type.
    func load<Item: PersistentModel>() throws -> [Item] {
        return try context.fetch(FetchDescriptor<Item>())
    }
}



// MARK: - Extension Dependencies
extension String {
    /// Appends a path component to the string, ensuring there is exactly one separating slash,
    /// and returns a string that always ends with a trailing slash.
    ///
    /// - Parameter path: The path component to append.
    /// - Returns: A combined path string ending with a `/`.
    func appendingPathComponent(_ path: String) -> String {
        let selfHasSlash = self.hasSuffix("/")
        let pathHasSlash = path.hasPrefix("/")
        
        let combinedPath: String
        if selfHasSlash && pathHasSlash {
            combinedPath = self + String(path.dropFirst())
        } else if !selfHasSlash && !pathHasSlash {
            combinedPath = self + "/" + path
        } else {
            combinedPath = self + path
        }
        
        return combinedPath.hasSuffix("/") ? combinedPath : combinedPath + "/"
    }
}
