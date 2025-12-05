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
        fatalError() // TODO: -
    }
}
