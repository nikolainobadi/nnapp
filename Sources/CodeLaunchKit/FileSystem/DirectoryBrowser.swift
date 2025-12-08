//
//  DirectoryBrowser.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol DirectoryBrowser {
    func browseForDirectory(prompt: String) throws -> Directory
}
