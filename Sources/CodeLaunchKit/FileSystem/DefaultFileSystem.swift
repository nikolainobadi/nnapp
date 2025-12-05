//
//  DefaultFileSystem.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/11/25.
//

import Files
import Foundation

public struct DefaultFileSystem {
    public init() { }
}


// MARK: - FileSystem
extension DefaultFileSystem: FileSystem {
    public var homeDirectory: any Directory {
        return FilesDirectoryAdapter(folder: Folder.home)
    }
    
    public func directory(at path: String) throws -> any Directory {
        return try FilesDirectoryAdapter(folder: Folder(path: path))
    }
    
    public func desktopDirectory() throws -> any Directory {
        return try directory(at: FileManager.default.homeDirectoryForCurrentUser.path())
    }
}
