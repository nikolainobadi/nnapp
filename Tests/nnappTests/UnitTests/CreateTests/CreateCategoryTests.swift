//
//  CreateCategoryTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
@testable import nnapp
@preconcurrency import Files

@MainActor
final class CreateCategoryTests: MainActorBaseCreateTests {
    private let categoryName = "categoryName"
    
    private var parentPath: String {
        return tempFolder.path
    }
}


// MARK: - Unit Tests
extension CreateCategoryTests {
    @Test("Throws an error when a folder already exists in the parent directory with same name")
    func throwsErrorWhenFolderAlreadyExists() throws {
        let _ = try #require(try tempFolder.createSubfolder(named: categoryName))
        
        #expect(throws: CodeLaunchError.categoryPathTaken) {
            try runCategoryCommand()
        }
    }
    
    @Test("Throws an error when the name is taken by an existing Category")
    func throwsErrorWhenCategoryNameAlreadyExists() throws {
        let existingCategoryFolder = try #require(try tempFolder.createSubfolder(named: categoryName))
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        let category = makeCategory(name: categoryName, path: existingCategoryFolder.path)
        
        try context.saveCategory(category)
        
        #expect(throws: CodeLaunchError.categoryNameTaken) {
            try runCategoryCommand(factory: factory)
        }
    }
    
    @Test("Creates a new folder for the new category", arguments: TestInfo.testOptions)
    func createCategoryFolder(info: TestInfo) throws {
        let picker = MockPicker(requiredInputResponses: makeCategoryInputs(info: info))
        let factory = MockContextFactory(picker: picker)
        
        try runCategoryCommand(factory: factory, info: info)
        
        let updatedFolder = try #require(try Folder(path: parentPath))
        let _ = try #require(updatedFolder.containsSubfolder(named: categoryName))
    }
    
    @Test("Saves the new category", arguments: TestInfo.testOptions)
    func savesNewCategory(info: TestInfo) throws {
        let picker = MockPicker(requiredInputResponses: makeCategoryInputs(info: info))
        let factory = MockContextFactory(picker: picker)
        
        try runCategoryCommand(factory: factory, info: info)
        
        let categories = try factory.makeContext().loadCategories()
        let savedCategory = try #require(categories.first)
        
        #expect(categories.count == 1)
        #expect(savedCategory.groups.isEmpty)
        #expect(savedCategory.name == categoryName)
        
        #expect(savedCategory.path == parentPath.appendingPathComponent(categoryName))
    }
}


// MARK: - RunCommand
private extension CreateCategoryTests {
    func runCategoryCommand(factory: MockContextFactory? = nil, info: TestInfo = .init(name: .arg, otherArg: .arg)) throws {
        try runCommand(
            factory,
            argType: .category(
                name: info.name == .arg ? categoryName : nil,
                parentPath: info.otherArg == .arg ? parentPath : nil
            )
        )
    }
}


// MARK: - Helpers
private extension CreateCategoryTests {
    func makeCategoryInputs(info: TestInfo) -> [String] {
        var inputs = [String]()
        
        if info.name == .input {
            inputs.append(categoryName)
        }
        
        if info.otherArg == .input {
            inputs.append(tempFolder.path)
        }
        
        return inputs
    }
}
