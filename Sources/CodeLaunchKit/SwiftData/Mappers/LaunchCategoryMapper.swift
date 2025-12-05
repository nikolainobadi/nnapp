//
//  LaunchCategoryMapper.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

enum LaunchCategoryMapper {
    static func toDomain(_ category: SwiftDataLaunchCategory) -> LaunchCategory {
        // TODO: - set LaunchGroup.category and LaunchProject.group
        let categorySummary = LaunchGroup.Category(name: category.name, path: category.path)
        let groups = category.groups.map({ LaunchGroupMapper.toDomain($0, category: categorySummary) })

        return .init(name: category.name, path: category.path, groups: groups)
    }

    static func toSwiftData(_ category: LaunchCategory) -> SwiftDataLaunchCategory {
        return .init(name: category.name, path: category.path)
    }
}
