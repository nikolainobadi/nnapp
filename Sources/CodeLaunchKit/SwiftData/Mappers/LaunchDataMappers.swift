//
//  LaunchDataMappers.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import Foundation

struct LaunchCategoryMapper {
    private let groupMapper = LaunchGroupMapper()

    func toDomain(_ category: SwiftDataLaunchCategory) -> LaunchCategory {
        let categorySummary = LaunchGroup.Category(name: category.name, path: category.path)
        let groups = category.groups.map({ groupMapper.toDomain($0, category: categorySummary) })

        return .init(name: category.name, path: category.path, groups: groups)
    }

    func toSwiftData(_ category: LaunchCategory) -> SwiftDataLaunchCategory {
        return .init(name: category.name, path: category.path)
    }
}


struct LaunchGroupMapper {
    private let projectMapper = LaunchProjectMapper()

    func toDomain(_ group: SwiftDataLaunchGroup, category: LaunchGroup.Category?) -> LaunchGroup {
        let groupPath = category?.path.appendingPathComponent(group.name)
        let projectGroup = LaunchProject.Group(name: group.name, path: groupPath)
        let projects = group.projects.map({ projectMapper.toDomain($0, group: projectGroup) })

        return .init(name: group.name, shortcut: group.shortcut, projects: projects, category: category)
    }

    func toSwiftData(_ group: LaunchGroup) -> SwiftDataLaunchGroup {
        return .init(name: group.name, shortcut: group.shortcut)
    }
}


struct LaunchProjectMapper {
    func toDomain(_ project: SwiftDataLaunchProject, group: LaunchProject.Group?) -> LaunchProject {
        let type = mapType(project.type)
        let remote = project.remote.map(mapLink)
        let links = project.links.map(mapLink)

        return .init(
            name: project.name,
            shortcut: project.shortcut,
            type: type,
            remote: remote,
            links: links,
            group: group
        )
    }

    func toSwiftData(_ project: LaunchProject) -> SwiftDataLaunchProject {
        let type = mapType(project.type)
        let remote = project.remote.map(mapLink)
        let links = project.links.map(mapLink)

        return .init(
            name: project.name,
            shortcut: project.shortcut,
            type: type,
            remote: remote,
            links: links
        )
    }
}


// MARK: - Helpers
private extension LaunchProjectMapper {
    func mapType(_ type: FirstSchema.ProjectType) -> ProjectType {
        switch type {
        case .project:
            return .project
        case .package:
            return .package
        case .workspace:
            return .workspace
        }
    }

    func mapType(_ type: ProjectType) -> FirstSchema.ProjectType {
        switch type {
        case .project:
            return .project
        case .package:
            return .package
        case .workspace:
            return .workspace
        }
    }

    func mapLink(_ link: FirstSchema.ProjectLink) -> ProjectLink {
        return .init(name: link.name, urlString: link.urlString)
    }

    func mapLink(_ link: ProjectLink) -> FirstSchema.ProjectLink {
        return .init(name: link.name, urlString: link.urlString)
    }
}
