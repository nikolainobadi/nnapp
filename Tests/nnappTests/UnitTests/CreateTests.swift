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
    @Test("Throws an error when a folder already exists in the parent directory with same name")
    func throwsErrorWhenFolderAlreadyExists() {
        // TODO: -
    }
    
    @Test("Throws an error when the name is taken by an existing Category")
    func throwsErrorWhenCategoryNameAlreadyExists() {
        // TODO: -
    }
    
    @Test("Creates a new folder for the new category", arguments: TestInfo.testOptions)
    func createCategoryFolder(info: TestInfo) throws {
        let parentPath = categoryListFolder.path
        let picker = MockPicker(requiredInputResponses: makeCategoryInputs(info: info))
        let factory = MockContextFactory(picker: picker)
        
        try runCommand(
            factory,
            argType: .category(
                name: info.name == .arg ? .categoryName : nil,
                parentPath: info.otherArg == .arg ? parentPath : nil
            )
        )
        
        let updatedFolder = try #require(try Folder(path: parentPath))
        let _ = try #require(updatedFolder.containsSubfolder(named: .categoryName))
    }
    
    @Test("Saves the new category", arguments: TestInfo.testOptions)
    func savesNewCategory(info: TestInfo) throws {
        let parentPath = categoryListFolder.path
        let picker = MockPicker(requiredInputResponses: makeCategoryInputs(info: info))
        let factory = MockContextFactory(picker: picker)
        
        try runCommand(
            factory,
            argType: .category(
                name: info.name == .arg ? .categoryName : nil,
                parentPath: info.otherArg == .arg ? parentPath : nil
            )
        )
        
        let categories = try factory.makeContext().loadCategories()
        let savedCategory = try #require(categories.first)
        
        #expect(categories.count == 1)
        #expect(savedCategory.groups.isEmpty)
        #expect(savedCategory.name == .categoryName)
        
        #expect(savedCategory.path == parentPath.appendingPathComponent(.categoryName))
    }
}


// MARK: - Group Tests
extension CreateTests {
    @Test("Creates a new Group folder in an existing Category folder")
    func createsNewGroupFolderInExistingCategoryFolder() throws {
        // TODO: -
    }
    
    @Test("Saves a new Group in an existing Category")
    func savesNewGroupInExistingCategory() throws {
        // TODO: -
    }
    
    @Test("Creates a new Group folder in a newly created Category folder.")
    func createsNewGroupFolderInNewCategoryFolder() throws {
        // TODO: -
    }
    
    @Test("Saves a new Group in a newly created category.")
    func savesNewGroupInNewCategory() throws {
        // TODO: -
    }
}


// MARK: - Factory
private extension CreateTests {
    func makeCategoryInputs(info: TestInfo) -> [String] {
        var inputs = [String]()
        
        if info.name == .input {
            inputs.append(.categoryName)
        }
        
        if info.otherArg == .input {
            inputs.append(categoryListFolder.path)
        }
        
        return inputs
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
extension CreateTests {
    struct TestInfo {
        let name: ArgOrInput
        let otherArg: ArgOrInput
        
        enum ArgOrInput {
            case arg, input
        }
        
        static var testOptions: [TestInfo] {
            return [
                TestInfo(name: .input, otherArg: .input),
//                TestInfo(name: .arg, otherArg: .input),
//                TestInfo(name: .arg, otherArg: .arg),
//                TestInfo(name: .input, otherArg: .arg)
            ]
        }
    }
}

fileprivate enum CreateArgs {
    case category(name: String?, parentPath: String?)
    case group(name: String?, category: String?)
}

fileprivate extension String {
    static var categoryName: String {
        return "categoryName"
    }
    
    static var parentPath: String {
        return "path/to/parent"
    }
}
