//
//  LaunchGroupMapper.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

enum LaunchGroupMapper {
    static func toDomain(_ group: SwiftDataLaunchGroup, category: LaunchGroup.Category?) -> LaunchGroup {
        let groupPath = category?.path.appendingPathComponent(group.name)
        let projectGroup = LaunchProject.Group(name: group.name, path: groupPath)
        let projects = group.projects.map({ LaunchProjectMapper.toDomain($0, group: projectGroup) })

        return .init(name: group.name, shortcut: group.shortcut, projects: projects, category: category)
    }

    static func toSwiftData(_ group: LaunchGroup) -> SwiftDataLaunchGroup {
        return .init(name: group.name, shortcut: group.shortcut)
    }
}
