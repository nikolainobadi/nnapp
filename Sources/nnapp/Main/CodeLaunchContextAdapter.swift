//
//  CodeLaunchContextAdapter.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

final class CodeLaunchContextAdapter {
    private let repository: SwiftDataLaunchRepository
    
    init(context: CodeLaunchContext) {
        self.repository = SwiftDataLaunchRepository(context: context)
    }
}


// MARK: -
extension CodeLaunchContextAdapter: LaunchListLoader, FinderInfoLoader {
    func loadCategories() throws -> [LaunchCategory] {
        return try repository.loadCategories()
    }
    
    func loadGroups() throws -> [LaunchGroup] {
        return try repository.loadGroups()
    }
    func loadProjects() throws -> [LaunchProject] {
        return try repository.loadProjects()
    }
    
    func loadProjectLinkNames() -> [String] {
        return repository.loadProjectLinkNames()
    }
}


// MARK: - Stores
extension CodeLaunchContextAdapter: CategoryStore, LaunchGroupStore, LaunchProjectStore {
    func saveCategory(_ category: LaunchCategory) throws {
        try repository.saveCategory(category)
    }
    
    func deleteCategory(_ category: LaunchCategory) throws {
        try repository.deleteCategory(category)
    }
    
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory) throws {
        try repository.saveGroup(group, in: category)
    }
    
    func deleteGroup(_ group: LaunchGroup, from category: LaunchCategory?) throws {
        try repository.deleteGroup(group, from: category)
    }
    
    func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
        try repository.saveProject(project, in: group)
    }
    
    func deleteProject(_ project: LaunchProject, from group: LaunchGroup?) throws {
        try repository.deleteProject(project, from: group)
    }
}
