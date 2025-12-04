//
//  GitShellAdapter.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import NnShellKit
import GitShellKit

struct GitShellAdapter {
    private let shell: any Shell
    
    init(shell: any Shell) {
        self.shell = shell
    }
}


// MARK: - GitShell
extension GitShellAdapter: GitShell {
    func runWithOutput(_ command: String) throws -> String {
        return try shell.bash(command)
    }
}
