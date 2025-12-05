//
//  LaunchProjectFolder.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import Files
import CodeLaunchKit

struct LaunchProjectFolder {
    let folder: Folder
    let type: ProjectType

    /// The name of the folder, used as the project name.
    var name: String {
        return folder.name
    }
}
