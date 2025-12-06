//
//  DefaultShell.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import NnShellKit
import GitShellKit

struct DefaultShell {
    private let shell: NnShell = .init()
}

extension DefaultShell: GitShell {
    func runWithOutput(_ command: String) throws -> String {
        return try shell.bash(command)
    }
}

extension DefaultShell: LaunchGitShell {
    func bash(_ command: String) throws -> String {
        return try shell.bash(command)
    }
    
    func runAndPrint(bash command: String) throws {
        try shell.runAndPrint(bash: command)
    }
    
    func run(_ program: String, args: [String]) throws -> String {
        return try shell.run(program, args: args)
    }
}
