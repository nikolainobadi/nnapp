//
//  MainActorBaseAddTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

@testable import nnapp

@MainActor
class MainActorBaseAddTests: MainActorTempFolderDatasource {
    enum ArgType {
        case category(path: String?)
        case group(path: String?, category: String?)
        case project(path: String?, group: String?, shortcut: String?, isMainProject: Bool)
    }

    static func runAddCommand(_ factory: MockContextFactory? = nil, argType: ArgType) throws {
        var args = ["add"]

        switch argType {
        case .category(let path):
            args.append("category")

            if let path {
                args.append(path)
            }
        case .group(let path, let category):
            args.append("group")

            if let path {
                args.append(path)
            }

            if let category {
                args.append(contentsOf: ["-c", category])
            }
        case .project(let path, let group, let shortcut, let isMain):
            args.append("project")

            if let path {
                args.append(path)
            }

            if let group {
                args.append(contentsOf: ["-g", group])
            }

            if let shortcut {
                args.append(contentsOf: ["-s", shortcut])
            }

            if isMain {
                args.append("--main-project")
            }
        }

        try Nnapp.testRun(contextFactory: factory, args: args)
    }
}
