//
//  MockShell+LaunchShell.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import GitCommandGen
import NnShellTesting
@testable import nnapp

final class MockLaunchShell: MockShell {
    
}

extension MockLaunchShell: LaunchGitShell {
    public func remoteExists(path: String?) throws -> Bool {
        return true // TODO: -
    }
    
    public func localGitExists(at path: String?) throws -> Bool {
        return true // TODO: -
    }
    
    public func runGitCommandWithOutput(_ command: GitShellCommand, path: String?) throws -> String {
        return "" // TODO: -
    }
    
    public func getGitHubURL(at path: String?) throws -> String {
        let pathDescription = path ?? "nil"
        let command = "getGitHubURL \(pathDescription)"

        return try run(command, args: [])
    }
}
