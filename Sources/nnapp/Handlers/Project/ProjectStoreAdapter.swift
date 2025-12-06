//
//  ProjectStoreAdapter.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/6/25.
//

import CodeLaunchKit

final class ProjectStoreAdapter {
    private let groupHandler: GroupHandler
    private let repository: SwiftDataLaunchRepository
    
    init(groupHandler: GroupHandler, repository: SwiftDataLaunchRepository) {
        self.groupHandler = groupHandler
        self.repository = repository
    }
}


// MARK: - ProjectStore
extension ProjectStoreAdapter: ProjectStore {
    func loadGroups() throws -> [LaunchGroup] {
        return try repository.loadGroups()
    }
    
    func loadProjects() throws -> [LaunchProject] {
        return try repository.loadProjects()
    }
    
    func loadProjectLinkNames() -> [String] {
        return repository.loadProjectLinkNames()
    }
    
    func deleteGroup(_ group: LaunchGroup) throws {
        try groupHandler.deleteGroup(group)
    }
    
    func deleteProject(_ project: LaunchProject) throws {
        try repository.deleteProject(project)
    }
    
    func updateGroup(_ group: LaunchGroup) throws {
        // TODO: - 
    }
    
    func updateProject(_ project: LaunchProject) throws {
        // TODO: -
    }
    
    func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
        try repository.saveProject(project, in: group)
    }
}
