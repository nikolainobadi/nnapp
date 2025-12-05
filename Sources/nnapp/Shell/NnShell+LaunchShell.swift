//
//  NnShell+LaunchShell.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import NnShellKit
import GitShellKit

extension NnShell: LaunchShell, @retroactive GitShell {
    public func runWithOutput(_ command: String) throws -> String {
        return try bash(command)
    }
}
