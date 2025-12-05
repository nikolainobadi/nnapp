//
//  Script.swift
//  nnapp
//
//  Created by OpenAI Codex on 2024-06-06.
//

import Foundation
import ArgumentParser
import SwiftPickerKit

extension Nnapp {
    struct Script: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Manage the launch script that runs with `nnapp open`.",
            subcommands: [
                Set.self,
                Show.self,
                Delete.self
            ]
        )
    }
}

// MARK: - Show
extension Nnapp.Script {
    struct Show: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display the currently configured launch script"
        )

        func run() throws {
            if let script = try Nnapp.makeRepository().loadLaunchScript() {
                print(script)
            } else {
                print("No launch script configured")
            }
        }
    }
}

// MARK: - Set
extension Nnapp.Script {
    struct Set: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Add or update the launch script"
        )

        @Argument(help: "The script to run when opening a project")
        var script: String?

        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeRepository()
            let script = try script ?? picker.getRequiredInput("Enter the launch script to run with `nnapp open`")
            
            context.saveLaunchScript(script)
            print("Saved launch script")
        }
    }
}

// MARK: - Delete
extension Nnapp.Script {
    struct Delete: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Remove the saved launch script"
        )

        func run() throws {
            let picker = Nnapp.makePicker()
            let context = try Nnapp.makeRepository()

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
