//
//  SwiftDataLaunchRepository.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import Foundation

/// SwiftData-backed repository that translates between persistence models and domain models.
public final class SwiftDataLaunchRepository {
    private let context: CodeLaunchContext
    private let categoryMapper = LaunchCategoryMapper()
    private let groupMapper = LaunchGroupMapper()
    private let projectMapper = LaunchProjectMapper()

    public init(context: CodeLaunchContext) {
        self.context = context
    }
}


// MARK: - Loaders
extension SwiftDataLaunchRepository: LaunchListLoader, FinderInfoLoader, LaunchProjectInfoLoader {
    public func loadCategories() throws -> [LaunchCategory] {
        let categories = try context.loadCategories()
        return categories.map { categoryMapper.toDomain($0) }
    }

    public func loadGroups() throws -> [LaunchGroup] {
        return try loadCategories().flatMap(\.groups)
    }

    public func loadProjects() throws -> [LaunchProject] {
        return try loadGroups().flatMap(\.projects)
    }

    public func loadProjectLinkNames() -> [String] {
        return context.loadProjectLinkNames()
    }
}


// MARK: - Stores
extension SwiftDataLaunchRepository: CategoryStore, LaunchGroupStore, LaunchProjectStore {
    public func saveCategory(_ category: LaunchCategory) throws {
        let storedCategory = categoryMapper.toSwiftData(category)
        try context.saveCategory(storedCategory)
    }

    public func deleteCategory(_ category: LaunchCategory) throws {
        guard let storedCategory = try fetchCategory(named: category.name) else {
            throw CodeLaunchError.missingCategory
        }

        try context.deleteCategory(storedCategory)
    }

    public func saveGroup(_ group: LaunchGroup, in category: LaunchCategory) throws {
        let storedCategory: SwiftDataLaunchCategory
        if let existingCategory = try fetchCategory(named: category.name) {
            storedCategory = existingCategory
        } else {
            let newCategory = categoryMapper.toSwiftData(category)
            try context.saveCategory(newCategory)
            storedCategory = newCategory
        }

        let storedGroup = groupMapper.toSwiftData(group)
        try context.saveGroup(storedGroup, in: storedCategory)
    }

    public func deleteGroup(_ group: LaunchGroup, from category: LaunchCategory?) throws {
        guard let storedGroup = try fetchGroup(named: group.name, categoryName: category?.name) else {
            throw CodeLaunchError.missingGroup
        }

        try context.deleteGroup(storedGroup)
    }

    public func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
        guard let storedGroup = try fetchGroup(named: group.name, categoryName: group.categoryName) else {
            throw CodeLaunchError.missingGroup
        }

        let storedProject = projectMapper.toSwiftData(project)
        try context.saveProject(storedProject, in: storedGroup)
    }

    public func deleteProject(_ project: LaunchProject, from group: LaunchGroup?) throws {
        guard let storedProject = try fetchProject(named: project.name, shortcut: project.shortcut, groupName: group?.name) else {
            throw CodeLaunchError.missingProject
        }

        try context.deleteProject(storedProject)
    }
}


// MARK: - Helpers
private extension SwiftDataLaunchRepository {
    func fetchCategory(named name: String) throws -> SwiftDataLaunchCategory? {
        return try context.loadCategories().first { $0.name.lowercased() == name.lowercased() }
    }

    func fetchGroup(named name: String, categoryName: String?) throws -> SwiftDataLaunchGroup? {
        let groups = try context.loadGroups()

        return groups.first { group in
            guard group.name.lowercased() == name.lowercased() else {
                return false
            }

            if let categoryName {
                return group.category?.name.lowercased() == categoryName.lowercased()
            }

            return true
        }
    }

    func fetchProject(named name: String, shortcut: String?, groupName: String?) throws -> SwiftDataLaunchProject? {
        let projects = try context.loadProjects()

        return projects.first { project in
            let nameMatches = project.name.lowercased() == name.lowercased()
            let shortcutMatches = {
                guard let shortcut, let projectShortcut = project.shortcut else { return false }
                return projectShortcut.lowercased() == shortcut.lowercased()
            }()

            let groupMatches: Bool
            if let groupName {
                groupMatches = project.group?.name.lowercased() == groupName.lowercased()
            } else {
                groupMatches = true
            }

            return groupMatches && (nameMatches || shortcutMatches)
        }
    }
}
