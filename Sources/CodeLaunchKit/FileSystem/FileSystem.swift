//
//  FileSystem.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol FileSystem {
    var homeDirectory: Directory { get }
    
    func directory(at path: String) throws -> Directory
    func desktopDirectory() throws -> Directory
}
