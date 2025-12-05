//
//  FileSystem.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol FileSystem {
    var homeDirectory: any Directory { get }
    
    func directory(at path: String) throws -> any Directory
    func desktopDirectory() throws -> any Directory
}
