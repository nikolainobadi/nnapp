//
//  TempFolderDatasource.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Foundation
@testable import nnapp
@preconcurrency import Files

@MainActor
class MainActorTempFolderDatasource {
    let tempFolder: Folder
    
    init(testFolder: TestFolder = .init(name: "nnappTempSubFolder", subFolders: [])) throws {
        self.tempFolder = try Folder.temporary.createSubfolder(named: "\(UUID().uuidString)_\(testFolder.name)")
        
        try createSubfolders(in: tempFolder, subFolders: testFolder.subFolders)
    }
    
    deinit {
        deleteFolderContents(tempFolder)
    }
}


// MARK: - Dependencies
struct TestFolder {
    let name: String
    let subFolders: [TestFolder]
}

fileprivate func createSubfolders(in folder: Folder, subFolders: [TestFolder]) throws {
    for sub in subFolders {
        let newFolder = try folder.createSubfolder(named: sub.name)
        try createSubfolders(in: newFolder, subFolders: sub.subFolders)
    }
}
