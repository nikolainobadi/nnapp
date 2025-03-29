//
//  FactoryMethods.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

@testable import nnapp

func makeCategory(name: String = "iOSApps", path: String = "path/to/category") -> LaunchCategory {
    return .init(name: name, path: path)
}

func makeGroup(name: String = "MyGroup", shortcut: String? = nil) -> LaunchGroup {
    return .init(name: name, shortcut: shortcut)
}

func makeProject(name: String = "MyProject", shorcut: String? = nil) -> LaunchProject {
    return .init(name: name, shortcut: shorcut, type: .package, remote: nil, links: [])
}
