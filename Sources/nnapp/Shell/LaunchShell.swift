//
//  LaunchShell.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

protocol LaunchShell {
    func bash(_ command: String) throws -> String
    func runAndPrint(bash command: String) throws
    func getGitHubURL(at path: String?) throws -> String
    func run(_ program: String, args: [String]) throws -> String
}

extension LaunchShell {
    func runAppleScript(script: String) throws -> String {
        return try run("/usr/bin/osascript", args: ["-e", script])
    }
}
