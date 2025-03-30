//
//  ProjectFolder.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Files

struct ProjectFolder {
    let folder: Folder
    let type: ProjectType
    
    var name: String {
        return folder.name
    }
}
