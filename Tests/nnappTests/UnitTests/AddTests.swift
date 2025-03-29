//
//  File.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
@testable import nnapp
@preconcurrency import Files

@MainActor
final class AddTests {
    private let categoryListFolder: Folder
    private let categoryName = "categoryName"
    
    init() throws {
        self.categoryListFolder = try Folder.temporary.createSubfolder(named: "categoryListFolder")
    }
    
    deinit {
        deleteFolderContents(categoryListFolder)
    }
}


// MARK: - Category Tests
extension AddTests {
    @Test("Throws an error when the name of imported folder already exists in a Category")
    func throwsErrorWhenFolderNameIsTaken() {
        // TODO: -
    }
}


// MARK: - RunCommand
private extension AddTests {
    func runCommand(_ factory: MockContextFactory, argType: ArgType) throws {
        var args = ["add"]
        
        switch argType {
        case .category(let path):
            if let path {
                args.append(path)
            }
        }
        
        try Nnapp.testRun(contextFactory: factory, args: args)
    }
}


// MARK: - Dependencies
extension AddTests {
    enum ArgType {
        case category(path: String?)
    }
}
