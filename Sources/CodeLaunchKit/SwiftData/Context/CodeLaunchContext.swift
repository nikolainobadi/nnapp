//
//  CodeLaunchContext.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import SwiftData
import Foundation
import NnSwiftDataKit

/// Manages loading, saving, and deleting Categories, Groups, and Projects from SwiftData and UserDefaults.
/// Acts as the primary interface to CodeLaunch's persistent state.
public final class CodeLaunchContext {
    private let context: ModelContext
    private let defaults: UserDefaults
    private let launchScriptKey = "launchScriptKey"
    private let projectLinkNameListKey = "projectLinkNameListKey"

    init(schema: Schema, testConfig: ModelConfiguration? = nil, userDefaultsTestSuiteName: String? = nil) throws {
        let identifier = "com.nobadi.codelaunch"
        let oldAppGroupId = "R8SJ24LQF3.\(identifier)"
        let appGroupId = "group.\(identifier)"
        
        if let testConfig, let userDefaultsTestSuiteName {
            defaults = .init(suiteName: userDefaultsTestSuiteName)!
            defaults.removePersistentDomain(forName: userDefaultsTestSuiteName)
            context = try .init(.init(for: schema, configurations: testConfig))
        } else {
            try migrateAppGroupSwiftDataStoreIfNeeded(from: oldAppGroupId, to: appGroupId)
            let (container, defaults) = try makeAppGroupModelContainer(schema: schema, appGroupId: appGroupId)
            
            self.defaults = defaults
            self.context = .init(container)
        }
    }
}


// MARK: - Init
public extension CodeLaunchContext {
    convenience init(config: ModelConfiguration? = nil, userDefaultsTestSuiteName: String? = nil) throws {
        try self.init(schema: .init(versionedSchema: FirstSchema.self), testConfig: config, userDefaultsTestSuiteName: userDefaultsTestSuiteName)
    }
}


// MARK: - Load
public extension CodeLaunchContext {
    /// Loads all saved launch categories from the SwiftData context.
    /// - Returns: An array of `LaunchCategory` objects.
    func loadCategories() throws -> [SwiftDataLaunchCategory] {
        return try load()
    }

    /// Loads all saved launch groups from the SwiftData context.
    /// - Returns: An array of `LaunchGroup` objects.
    func loadGroups() throws -> [SwiftDataLaunchGroup] {
        return try load()
    }

    /// Loads all saved launch projects from the SwiftData context.
    /// - Returns: An array of `LaunchProject` objects.
    func loadProjects() throws -> [SwiftDataLaunchProject] {
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
public extension CodeLaunchContext {
    /// Persists a new launch category to the SwiftData context.
    /// - Parameter category: The category to save.
    func saveCategory(_ category: SwiftDataLaunchCategory) throws {
        context.insert(category)
        try context.save()
    }

    /// Persists a new launch group under the specified category.
    /// - Parameters:
    ///   - group: The group to save.
    ///   - category: The parent category to associate with.
    func saveGroup(_ group: SwiftDataLaunchGroup, in category: SwiftDataLaunchCategory) throws {
        context.insert(group)
        group.category = category
        category.groups.append(group)

        try context.save()
    }

    /// Persists a new launch project under the specified group.
    /// - Parameters:
    ///   - project: The project to save.
    ///   - group: The parent group to associate with.
    func saveProject(_ project: SwiftDataLaunchProject, in group: SwiftDataLaunchGroup) throws {
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

    /// Persists the launch script string to UserDefaults.
    /// - Parameter script: The script to save.
    func saveLaunchScript(_ script: String) {
        defaults.set(script, forKey: launchScriptKey)
    }
}


// MARK: - Update
public extension CodeLaunchContext {
    /// Persists changes to an existing launch group.
    /// - Parameters:
    ///   - group: The stored group instance to update.
    ///   - name: The updated display name for the group.
    ///   - shortcut: The shortcut to associate with the group.
    func updateGroup(_ group: SwiftDataLaunchGroup, name: String, shortcut: String?) throws {
        group.name = name
        group.shortcut = shortcut

        try context.save()
    }

    /// Persists changes to an existing launch project.
    /// - Parameters:
    ///   - project: The stored project instance to update.
    ///   - name: The updated display name for the project.
    ///   - shortcut: The shortcut to associate with the project.
    ///   - type: The updated project type.
    ///   - remote: The remote link to associate with the project, if any.
    ///   - links: The collection of links associated with the project.
    func updateProject(
        _ project: SwiftDataLaunchProject,
        name: String,
        shortcut: String?,
        type: FirstSchema.ProjectType,
        remote: FirstSchema.ProjectLink?,
        links: [FirstSchema.ProjectLink]
    ) throws {
        project.name = name
        project.shortcut = shortcut
        project.type = type
        project.remote = remote
        project.links = links

        try context.save()
    }
}


// MARK: - Delete
public extension CodeLaunchContext {
    /// Deletes a category and all associated groups and projects.
    /// - Parameter category: The category to delete.
    func deleteCategory(_ category: SwiftDataLaunchCategory) throws {
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
    func deleteGroup(_ group: SwiftDataLaunchGroup, skipSave: Bool = false) throws {
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
    func deleteProject(_ project: SwiftDataLaunchProject, skipSave: Bool = false) throws {
        context.delete(project)

        if !skipSave {
            try context.save()
        }
    }

    /// Removes the stored launch script from UserDefaults.
    func deleteLaunchScript() {
        defaults.removeObject(forKey: launchScriptKey)
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
