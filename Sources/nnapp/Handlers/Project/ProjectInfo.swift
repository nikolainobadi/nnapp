//
//  ProjectInfo.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

/// Stores project metadata gathered during setup, used to construct a `LaunchProject`.
struct ProjectInfo {
    let name: String
    let shortcut: String?
    let remote: ProjectLink?
    let otherLinks: [ProjectLink]
}
