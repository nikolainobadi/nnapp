//
//  MockLaunchShell.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import CodeLaunchKit
import GitCommandGen
import NnShellTesting
@testable import nnapp

final class MockLaunchShell: MockShell {
    private let localExists: Bool
    private let remoteExists: Bool
    private let githubURL: String?
    
    init(githubURL: String? = nil, localExists: Bool = true, remoteExists: Bool = true, results: [String] = [], shouldThrowErrorOnFinal: Bool = false) {
        self.githubURL = githubURL
        self.localExists = localExists
        self.remoteExists = remoteExists
        super.init(results: results, shouldThrowErrorOnFinal: shouldThrowErrorOnFinal)
    }

    init(githubURL: String? = nil, localExists: Bool = true, remoteExists: Bool = true, commands: [MockCommand] = []) {
        self.githubURL = githubURL
        self.localExists = localExists
        self.remoteExists = remoteExists
        super.init(commands: commands)
    }
}

extension MockLaunchShell: LaunchGitShell {
    public func remoteExists(path: String?) throws -> Bool {
        return remoteExists
    }
    
    public func localGitExists(at path: String?) throws -> Bool {
        return localExists
    }
    
    public func runGitCommandWithOutput(_ command: GitShellCommand, path: String?) throws -> String {
        return try bash(makeGitCommand(command, path: path))
    }
    
    public func getGitHubURL(at path: String?) throws -> String {
        return try bash(makeGitCommand(.getRemoteURL, path: path))
    }
}
