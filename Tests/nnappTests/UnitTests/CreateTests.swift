//
//  CreateTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Testing
@testable import nnapp
@preconcurrency import Files

@MainActor
final class CreateTests {
    private let categoryListFolder: Folder
    private let categoryName = "categoryName"
    
    init() throws {
        self.categoryListFolder = try Folder.temporary.createSubfolder(named: "categoryListFolder")
    }
    
    deinit {
        deleteFolderContents(categoryListFolder)
    }
}


// MARK: - Category Test
extension CreateTests {
    @Test("Creates a new folder for the new category", .disabled())
    func createCategoryFolder() throws {
        let requiredInputs = [categoryName, categoryListFolder.path]
        let picker = MockPicker(requiredInputResponses: requiredInputs)
        let factory = MockContextFactory(picker: picker)
        
        try runCommand(factory, argType: .category(name: nil, parentPath: nil))
        
        let updatedFolder = try #require(try Folder(path: categoryListFolder.path))
        let _ = try #require(updatedFolder.containsSubfolder(named: categoryName))
    }
    
    @Test("Creates a new folder for the new category with name from arg", .disabled())
    func createCategoryFolderWithNameArg() throws {
        let requiredInputs = [categoryListFolder.path]
        let picker = MockPicker(requiredInputResponses: requiredInputs)
        let factory = MockContextFactory(picker: picker)
        
        try runCommand(factory, argType: .category(name: categoryName, parentPath: nil))
        
        let updatedFolder = try #require(try Folder(path: categoryListFolder.path))
        let _ = try #require(updatedFolder.containsSubfolder(named: categoryName))
    }
}


// MARK: - Run Command
private extension CreateTests {
    func runCommand(_ factory: MockContextFactory, argType: CreateArgs?) throws {
        var args = ["create"]
        
        if let argType {
            switch argType {
            case .category(let name, let parentPath):
                args.append("category")
                
                if let name {
                    args.append(name)
                }
                
                if let parentPath {
                    args.append(contentsOf: ["-p", parentPath])
                }
                
            case .group(let name, let category):
                args.append("group")
                
                if let name {
                    args.append(name)
                }
                
                if let category {
                    args.append(contentsOf: ["-c", category])
                }
            }
        }
        
        try Nnapp.testRun(contextFactory: factory, args: args)
    }
}


// MARK: - Dependencies
fileprivate enum CreateArgs {
    case category(name: String?, parentPath: String?)
    case group(name: String?, category: String?)
}
