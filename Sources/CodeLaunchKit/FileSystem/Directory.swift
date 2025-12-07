//
//  Directory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol Directory {
    var path: String { get }
    var name: String { get }
    var `extension`: String? { get }
    var subdirectories: [Directory] { get }
    
    func containsFile(named name: String) -> Bool
    func subdirectory(named name: String) throws -> Directory
    func createSubdirectory(named name: String) throws -> Directory
    func move(to parent: Directory) throws
}
