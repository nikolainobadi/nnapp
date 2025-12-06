//
//  MockShell+LaunchShell.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import NnShellTesting
@testable import nnapp

extension MockShell: LaunchShell {
    public func getGitHubURL(at path: String?) throws -> String {
        let pathDescription = path ?? "nil"
        let command = "getGitHubURL \(pathDescription)"

        return try run(command, args: [])
    }
}
