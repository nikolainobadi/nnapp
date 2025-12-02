//
//  Script.swift
//  nnapp
//
//  Created by OpenAI Codex on 2024-06-06.
//

import Foundation
import ArgumentParser

/// Manage the terminal launch script executed alongside `nnapp open`.
extension Nnapp {
    struct Script: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Manage the launch script that runs with `nnapp open`.",
            subcommands: [Show.self, Set.self, Delete.self]
        )
    }
}

// MARK: - Show
extension Nnapp.Script {
    /// Displays the currently saved launch script, if one exists.
    struct Show: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display the currently configured launch script"
        )

        func run() throws {
            let context = try Nnapp.makeContext()
            if let script = context.loadLaunchScript() {
                print(script)
            } else {
                print("No launch script configured")
            }
        }
    }
}

// MARK: - Set
extension Nnapp.Script {
    /// Saves or updates the launch script used when opening projects.
    struct Set: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Add or update the launch script"
        )

        @Argument(help: "The script to run when opening a project")
        var script: String?

        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()
            let script = try script ?? picker.getRequiredInput("Enter the launch script to run with `nnapp open`")
            context.saveLaunchScript(script)
            print("Saved launch script")
        }
    }
}

// MARK: - Delete
extension Nnapp.Script {
    /// Removes the saved launch script from configuration.
    struct Delete: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Remove the saved launch script"
        )

        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeContext()

            guard let script = context.loadLaunchScript() else {
                print("No launch script configured")
                return
            }

            try picker.requiredPermission("Delete the existing launch script? \n\(script)")
            context.deleteLaunchScript()
            print("Launch script deleted")
        }
    }
}
