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


// MARK: - Load
extension SwiftDataLaunchRepository: LaunchListLoader, FinderInfoLoader, ProjectInfoLoader {
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

    public func loadLaunchScript() -> String? {
        return context.loadLaunchScript()
    }
}

// MARK: - Category
extension SwiftDataLaunchRepository: CategoryStore {
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
}


// MARK: - Group
extension SwiftDataLaunchRepository: LaunchGroupStore {
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
    
    public func updateGroup(_ group: LaunchGroup) throws {
        guard let storedGroup = try fetchGroup(named: group.name) else {
            throw CodeLaunchError.missingGroup
        }

        try context.updateGroup(storedGroup, name: group.name, shortcut: group.shortcut)
    }
    
    public func deleteGroup(_ group: LaunchGroup) throws {
        guard let storedGroup = try fetchGroup(named: group.name) else {
            throw CodeLaunchError.missingGroup
        }
        
        try context.deleteGroup(storedGroup)
    }
}



// MARK: - Project
extension SwiftDataLaunchRepository: ProjectStore {
    public func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
        guard let storedGroup = try fetchGroup(named: group.name) else {
            throw CodeLaunchError.missingGroup
        }

        let storedProject = projectMapper.toSwiftData(project)
        try context.saveProject(storedProject, in: storedGroup)
    }
    
    public func updateProject(_ project: LaunchProject) throws {
        guard let storedProject = try fetchProject(named: project.name) else {
            throw CodeLaunchError.missingProject
        }

        let mappedProject = projectMapper.toSwiftData(project)
        try context.updateProject(
            storedProject,
            name: mappedProject.name,
            shortcut: mappedProject.shortcut,
            type: mappedProject.type,
            remote: mappedProject.remote,
            links: mappedProject.links
        )
    }

    public func deleteProject(_ project: LaunchProject) throws {
        guard let storedProject = try fetchProject(named: project.name) else {
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

    func fetchGroup(named name: String) throws -> SwiftDataLaunchGroup? {
        return try context.loadGroups().first(where: { $0.name.matches(name) })
    }

    func fetchProject(named name: String) throws -> SwiftDataLaunchProject? {
        return try context.loadProjects().first(where: { $0.name.matches(name) })
    }
}
