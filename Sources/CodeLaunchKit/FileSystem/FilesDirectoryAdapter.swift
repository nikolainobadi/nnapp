//
//  FilesDirectoryAdapter.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/11/25.
//

import Files
import Foundation

struct FilesDirectoryAdapter {
    private let folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
}


// MARK: - Directory
extension FilesDirectoryAdapter: Directory {
    var path: String {
        return folder.path
    }
    
    var name: String {
        return folder.name
    }
    
    var `extension`: String? {
        return folder.extension
    }
    
    var subdirectories: [Directory] {
        return folder.subfolders.map(FilesDirectoryAdapter.init)
    }
    
    func containsFile(named name: String) -> Bool {
        return folder.containsFile(named: name)
    }
    
    func subdirectory(named name: String) throws -> Directory {
        return try FilesDirectoryAdapter(folder: folder.subfolder(named: name))
    }
    
    func createSubdirectory(named name: String) throws -> Directory {
        if let existing = try? folder.subfolder(named: name) {
            return FilesDirectoryAdapter(folder: existing)
        }
        
        return try FilesDirectoryAdapter(folder: folder.createSubfolder(named: name))
    }
    
    func move(to parent: Directory) throws {
        guard let destination = (parent as? FilesDirectoryAdapter)?.folder else {
            throw FileSystemError.incompatibleDirectory
        }
        
        try folder.move(to: destination)
    }
}
