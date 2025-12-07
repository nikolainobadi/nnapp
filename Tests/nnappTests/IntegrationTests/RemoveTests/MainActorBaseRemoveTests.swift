//
//  MainActorBaseRemoveTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
@testable import nnapp

@MainActor
class MainActorBaseRemoveTests: MainActorTempFolderDatasource {
    enum ArgType {
        case category(name: String?)
        case group(name: String?)
        case project(name: String?, shortcut: String?)
        case link
    }

    static func runRemoveCommand(_ factory: MockContextFactory?, argType: ArgType) throws {
        var args = ["remove"]

        switch argType {
        case .category(let name):
            args.append("category")

            if let name {
                args.append(name)
            }

        case .group(let name):
            args.append("group")

            if let name {
                args.append(name)
            }

        case .project(let name, let shortcut):
            args.append("project")

            if let name {
                args.append(name)
            }

            if let shortcut {
                args.append(contentsOf: ["--shortcut", shortcut])
            }

        case .link:
            args.append("link")
        }

        try Nnapp.testRun(contextFactory: factory, args: args)
    }
}
