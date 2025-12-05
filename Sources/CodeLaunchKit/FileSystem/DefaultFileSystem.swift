//
//  DefaultFileSystem.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/11/25.
//

import Files
import Foundation

struct DefaultFileSystem: FileSystem {
    var homeDirectory: Directory {
        return FilesDirectoryAdapter(folder: Folder.home)
    }
    
    func directory(at path: String) throws -> Directory {
        return try FilesDirectoryAdapter(folder: Folder(path: path))
    }
    
    func desktopDirectory() throws -> Directory {
        return try directory(at: FileManager.default.homeDirectoryForCurrentUser.path())
    }
}
