//
//  SetMainProject.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/31/25.
//

import ArgumentParser

/// Changes the main project for a group by allowing the user to select from available non-main projects.
extension Nnapp {
    struct SetMainProject: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Set or change the main project for a group by selecting from available projects."
        )

        /// The name or shortcut of the group to modify.
        @Argument(help: "The name or shortcut of the group to set the main project for.")
        var group: String?

        func run() throws {
            try Nnapp.makeGroupHandler().setMainProject(group: group)
        }
    }
}