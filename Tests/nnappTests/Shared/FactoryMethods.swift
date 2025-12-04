//
//  FactoryMethods.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

@testable import nnapp

func makeCategory(name: String = "iOSApps", path: String = "path/to/category") -> SwiftDataLaunchCategory {
    return .init(name: name, path: path)
}

func makeGroup(name: String = "MyGroup", shortcut: String? = nil) -> SwiftDataLaunchGroup {
    return .init(name: name, shortcut: shortcut)
}

func makeProject(name: String = "MyProject", shortcut: String? = nil, remote: SwiftDataProjectLink? = nil, links: [SwiftDataProjectLink] = []) -> SwiftDataLaunchProject {
    return .init(name: name, shortcut: shortcut, type: .package, remote: remote, links: links)
}
