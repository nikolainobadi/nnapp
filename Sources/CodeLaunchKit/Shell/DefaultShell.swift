//
//  DefaultShell.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import NnShellKit
import GitShellKit

public struct DefaultShell {
    private let shell: NnShell = .init()
    
    public init() { }
}

extension DefaultShell: GitShell {
    public func runWithOutput(_ command: String) throws -> String {
        return try shell.bash(command)
    }
}

extension DefaultShell: LaunchGitShell {
    public func bash(_ command: String) throws -> String {
        return try shell.bash(command)
    }
    
    public func runAndPrint(bash command: String) throws {
        try shell.runAndPrint(bash: command)
    }
    
    public func run(_ program: String, args: [String]) throws -> String {
        return try shell.run(program, args: args)
    }
}
