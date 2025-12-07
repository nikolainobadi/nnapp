//
//  FactoryMethods.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

@testable import CodeLaunchKit

// MARK: - Domain Models
func makeCategory(name: String = "TestCategory", path: String = "/tmp/testcategory", groups: [LaunchGroup] = []) -> LaunchCategory {
    return .init(name: name, path: path, groups: groups)
}

func makeGroup(name: String = "TestGroup", shortcut: String? = nil, projects: [LaunchProject] = [], category: LaunchGroup.Category? = nil) -> LaunchGroup {
    return .init(name: name, shortcut: shortcut, projects: projects, category: category)
}

func makeGroupCategory(name: String = "TestCategory", path: String = "/tmp/testgroup") -> LaunchGroup.Category {
    return .init(name: name, path: path)
}

func makeProject(name: String = "TestProject", shortcut: String? = nil, type: ProjectType = .package, remote: ProjectLink? = nil, links: [ProjectLink] = [], group: LaunchProject.Group? = nil) -> LaunchProject {
    return .init(name: name, shortcut: shortcut, type: type, remote: remote, links: links, group: group)
}

func makeProjectGroup(name: String = "TestGroup", path: String? = "/tmp/testgroup") -> LaunchProject.Group {
    return .init(name: name, path: path)
}

func makeProjectLink(name: String = "Website", urlString: String = "https://example.com") -> ProjectLink {
    return .init(name: name, urlString: urlString)
}


// MARK: - SwiftData Models
func makeSwiftDataCategory(name: String = "iOSApps", path: String = "path/to/category") -> SwiftDataLaunchCategory {
    return .init(name: name, path: path)
}

func makeSwiftDataGroup(name: String = "MyGroup", shortcut: String? = nil) -> SwiftDataLaunchGroup {
    return .init(name: name, shortcut: shortcut)
}

func makeSwiftDataProject(name: String = "MyProject", shortcut: String? = nil, remote: SwiftDataProjectLink? = nil, links: [SwiftDataProjectLink] = []) -> SwiftDataLaunchProject {
    return .init(name: name, shortcut: shortcut, type: .package, remote: remote, links: links)
}
