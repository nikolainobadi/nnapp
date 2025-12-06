//
//  LaunchDataContracts.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

// MARK: - Shared Loaders
public protocol CategoryLoading {
    func loadCategories() throws -> [LaunchCategory]
}

public protocol GroupLoading {
    func loadGroups() throws -> [LaunchGroup]
}

public protocol ProjectLoading {
    func loadProjects() throws -> [LaunchProject]
}

public protocol ProjectLinkNameLoading {
    func loadProjectLinkNames() -> [String]
}


// MARK: - Category
public protocol CategoryStore: CategoryLoading {
    func saveCategory(_ category: LaunchCategory) throws
    func deleteCategory(_ category: LaunchCategory) throws
}


// MARK: - Group
public protocol LaunchGroupCategorySelector {
    func getCategory(group: LaunchGroup) -> LaunchCategory?
    func selectCategory(named name: String?) throws -> LaunchCategory
}

public protocol LaunchGroupStore: GroupLoading {
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory) throws
    func deleteGroup(_ group: LaunchGroup, from category: LaunchCategory?) throws
}


// MARK: - Project
public protocol ProjectGroupSelector {
    func selectGroup(name: String?) throws -> LaunchGroup
    func getProjectGroup(project: LaunchProject) throws -> LaunchGroup?
}

public protocol ProjectInfoLoader: GroupLoading, ProjectLoading, ProjectLinkNameLoading { }

public protocol ProjectStore: ProjectInfoLoader {
    func updateGroup(_ group: LaunchGroup) throws
    func deleteGroup(_ group: LaunchGroup) throws
    func deleteProject(_ project: LaunchProject) throws
    func updateProject(_ project: LaunchProject) throws
    func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws
}


// MARK: - Loaders
public protocol LaunchHierarchyLoader: CategoryLoading, GroupLoading, ProjectLoading { }

public protocol LaunchListLoader: LaunchHierarchyLoader, ProjectLinkNameLoading { }

public protocol FinderInfoLoader: LaunchHierarchyLoader { }
