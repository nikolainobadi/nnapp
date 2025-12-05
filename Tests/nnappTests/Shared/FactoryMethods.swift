//
//  FactoryMethods.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

@testable import CodeLaunchKit

// MARK: - Domain Models
func makeProject(name: String = "TestProject", shortcut: String? = nil, type: ProjectType = .project, remote: ProjectLink? = nil, links: [ProjectLink] = [], group: LaunchProject.Group? = nil) -> LaunchProject {
    return .init(name: name, shortcut: shortcut, type: type, remote: remote, links: links, group: group)
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
