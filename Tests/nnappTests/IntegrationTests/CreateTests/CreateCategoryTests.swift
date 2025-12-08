//
//  CreateCategoryTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Files
import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

private let categoryName = "categoryName"

@MainActor
final class CreateCategoryTests: MainActorBaseCreateTests {
    private var parentPath: String {
        return tempFolder.path
    }
}


// MARK: - Tests
extension CreateCategoryTests {
    @Test("Throws an error when a folder already exists in the parent directory with same name")
    func throwsErrorWhenFolderAlreadyExists() throws {
        _ = try tempFolder.createSubfolder(named: categoryName)
        let parentPath = parentPath
        let factory = makeContextFactory()

        #expect(throws: CodeLaunchError.categoryPathTaken) {
            try runCategoryCommand(factory: factory, parentPath: parentPath)
        }
    }

    @Test("Throws an error when the name is taken by an existing Category")
    func throwsErrorWhenCategoryNameAlreadyExists() throws {
        let parentPath = parentPath
        let existingCategoryFolder = try tempFolder.createSubfolder(named: categoryName)
        let factory = makeContextFactory()
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory(name: categoryName, path: existingCategoryFolder.path)

        try context.saveCategory(category)

        #expect(throws: CodeLaunchError.categoryNameTaken) {
            try runCategoryCommand(factory: factory, parentPath: parentPath)
        }
    }

    @Test("Creates a new folder for the new category", arguments: MainActorBaseCreateTests.TestInfo.testOptions)
    func createCategoryFolder(info: MainActorBaseCreateTests.TestInfo) throws {
        let factory = makeContextFactory(inputResults: makeCategoryInputs(info: info))

        try runCategoryCommand(factory: factory, info: info, parentPath: parentPath)

        let updatedFolder = try Folder(path: parentPath)

        #expect(updatedFolder.containsSubfolder(named: categoryName))
    }

    @Test("Saves the new category", arguments: MainActorBaseCreateTests.TestInfo.testOptions)
    func savesNewCategory(info: MainActorBaseCreateTests.TestInfo) throws {
        let factory = makeContextFactory(inputResults: makeCategoryInputs(info: info))

        try runCategoryCommand(factory: factory, info: info, parentPath: parentPath)

        let categories = try factory.makeContext().loadCategories()
        let savedCategory = try #require(categories.first)

        #expect(categories.count == 1)
        #expect(savedCategory.groups.isEmpty)
        #expect(savedCategory.name == categoryName)

        #expect(savedCategory.path == parentPath.appendingPathComponent(categoryName))
    }
}


// MARK: - Helpers
private extension CreateCategoryTests {
    func makeCategoryInputs(info: MainActorBaseCreateTests.TestInfo) -> [String] {
        var inputs = [String]()

        if info.name == .input {
            inputs.append(categoryName)
        }

        return inputs
    }
    
    func makeContextFactory(inputResults: [String] = [], grantPermission: Bool = true) -> MockContextFactory {
        let selectedDirectory = FilesDirectoryAdapter(folder: tempFolder)
        let folderBrowser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let picker = MockSwiftPicker(inputResult: .init(type: .ordered(inputResults)), selectionResult: .init(defaultSingle: .index(grantPermission ? 0 : 1)))
        
        return .init(picker: picker, folderBrowser: folderBrowser)
    }
}


// MARK: - Run
@MainActor
private func runCategoryCommand(factory: MockContextFactory? = nil, info: MainActorBaseCreateTests.TestInfo = .init(name: .arg, otherArg: .arg), parentPath: String? = nil) throws {
    try MainActorBaseCreateTests.runCreateCommand(
        factory,
        argType: .category(
            name: info.name == .arg ? categoryName : nil,
            parentPath: info.otherArg == .arg ? parentPath : nil
        )
    )
}
