//
//  LaunchGitShell.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import GitShellKit

public protocol LaunchGitShell: LaunchShell {
    func remoteExists(path: String?) throws -> Bool
    func localGitExists(at path: String?) throws -> Bool
    func runGitCommandWithOutput(_ command: GitShellCommand, path: String?) throws -> String
}
