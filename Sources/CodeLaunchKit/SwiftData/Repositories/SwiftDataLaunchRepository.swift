//
//  SwiftDataLaunchRepository.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import Foundation

public final class SwiftDataLaunchRepository {
    private let context: CodeLaunchContext
    private let categoryMapper = LaunchCategoryMapper.self
    private let groupMapper = LaunchGroupMapper.self
    private let projectMapper = LaunchProjectMapper.self

    public init(context: CodeLaunchContext) {
        self.context = context
    }
}


// MARK: - Loaders
extension SwiftDataLaunchRepository: LaunchListLoader, FinderInfoLoader, ProjectInfoLoader {
    public func loadCategories() throws -> [LaunchCategory] {
        let categories = try context.loadCategories()
        return categories.map { categoryMapper.toDomain($0) }
    }

    public func loadGroups() throws -> [LaunchGroup] {
        // TODO: - need to set LaunchProject.category
        return try loadCategories().flatMap(\.groups)
    }

    public func loadProjects() throws -> [LaunchProject] {
        // TODO: - need to set LaunchProject.group
        return try loadGroups().flatMap(\.projects)
    }

    public func loadProjectLinkNames() -> [String] {
        return context.loadProjectLinkNames()
    }

    public func loadLaunchScript() -> String? {
        return context.loadLaunchScript()
    }
}


// MARK: - Stores
extension SwiftDataLaunchRepository: CategoryStore, LaunchGroupStore, ProjectStore {
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
    
    public func saveProjectLinkNames(_ names: [String]) {
        context.saveProjectLinkNames(names)
    }

    public func saveLaunchScript(_ script: String) {
        context.saveLaunchScript(script)
    }

    public func deleteLaunchScript() {
        context.deleteLaunchScript()
    }
}


// MARK: - Helpers
private extension SwiftDataLaunchRepository {
    func fetchCategory(named name: String) throws -> SwiftDataLaunchCategory? {
        return try context.loadCategories().first(where: { $0.name.matches(name) })
    }

    func fetchGroup(named name: String, categoryName: String?) throws -> SwiftDataLaunchGroup? {
        let groups = try context.loadGroups()

        return groups.first { group in
            guard group.name.matches(name) else {
                return false
            }

            if let categoryName {
                return categoryName.matches(group.category?.name)
            }

            return true
        }
    }

    func fetchProject(named name: String, shortcut: String?, groupName: String?) throws -> SwiftDataLaunchProject? {
        let projects = try context.loadProjects()

        return projects.first { project in
            let nameMatches = project.name.matches(name)
            let shortcutMatches = {
                guard let shortcut, let projectShortcut = project.shortcut else { return false }
                return shortcut.matches(projectShortcut)
            }()

            let groupMatches: Bool
            if let groupName {
                groupMatches = groupName.matches(project.group?.name)
            } else {
                groupMatches = true
            }

            return groupMatches && (nameMatches || shortcutMatches)
        }
    }
}
