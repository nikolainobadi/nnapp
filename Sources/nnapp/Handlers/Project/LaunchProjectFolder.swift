//
//  LaunchProjectFolder.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

struct LaunchProjectFolder {
    let folder: Directory
    let type: ProjectType

    /// The name of the folder, used as the project name.
    var name: String {
        return folder.name
    }
}
