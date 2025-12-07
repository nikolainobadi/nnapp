//
//  DirectoryBrowser.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol DirectoryBrowser {
    func browseForDirectory(prompt: String, startPath: String?) throws -> Directory
}


// MARK: - Convenience Method
public extension DirectoryBrowser {
    func browseForDirectory(prompt: String, startPath: String? = nil) throws -> Directory {
        return try browseForDirectory(prompt: prompt, startPath: startPath)
    }
}
