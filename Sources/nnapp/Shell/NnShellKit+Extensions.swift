//
//  NnShellKit+Extensions.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/1/25.
//

import NnShellKit

extension Shell {
    func runAppleScript(script: String) throws -> String {
        return try run("osascript", args: ["-e", script])
    }
}
