//
//  GitShellAdapter.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import GitShellKit

struct GitShellAdapter {
    private let shell: Shell
    
    init(shell: Shell) {
        self.shell = shell
    }
}


// MARK: - GitShell
extension GitShellAdapter: GitShell {
    func runWithOutput(_ command: String) throws -> String {
        return try shell.run(command)
    }
}
