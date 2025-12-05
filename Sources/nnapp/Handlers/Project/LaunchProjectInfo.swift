//
//  LaunchProjectInfo.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct LaunchProjectInfo {
    let name: String
    let shortcut: String?
    let remote: ProjectLink?
    let otherLinks: [ProjectLink]
}
