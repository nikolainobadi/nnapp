//
//  LaunchProjectMapper.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

enum LaunchProjectMapper {
    static func toDomain(_ project: SwiftDataLaunchProject, group: LaunchProject.Group?) -> LaunchProject {
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

    static func toSwiftData(_ project: LaunchProject) -> SwiftDataLaunchProject {
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


// MARK: - Private Methods
private extension LaunchProjectMapper {
    static func mapType(_ type: FirstSchema.ProjectType) -> ProjectType {
        switch type {
        case .project:
            return .project
        case .package:
            return .package
        case .workspace:
            return .workspace
        }
    }

    static func mapType(_ type: ProjectType) -> FirstSchema.ProjectType {
        switch type {
        case .project:
            return .project
        case .package:
            return .package
        case .workspace:
            return .workspace
        }
    }

    static func mapLink(_ link: FirstSchema.ProjectLink) -> ProjectLink {
        return .init(name: link.name, urlString: link.urlString)
    }

    static func mapLink(_ link: ProjectLink) -> FirstSchema.ProjectLink {
        return .init(name: link.name, urlString: link.urlString)
    }
}
