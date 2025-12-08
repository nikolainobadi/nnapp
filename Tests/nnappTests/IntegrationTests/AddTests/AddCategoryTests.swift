//
//  AddCategoryTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Files
import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

@MainActor
final class AddCategoryTests: MainActorBaseAddTests {
    @Test("Throws an error when the name of imported folder name is taken by an existing Category")
    func throwsErrorWhenFolderNameIsTaken() throws {
        let existingName = "existingCategory"
        let otherFolder = try tempFolder.createSubfolder(named: "OtherFolder")
        let categoryFolderToImport = try otherFolder.createSubfolder(named: existingName)
        let factory = makeContextFactory(categoryFolderToImport: categoryFolderToImport)
        let context = try factory.makeContext()
        let existingCategory = makeSwiftDataCategory(name: existingName, path: tempFolder.path.appendingPathComponent(existingName))

        try context.saveCategory(existingCategory)

        #expect(throws: CodeLaunchError.categoryNameTaken) {
            try runCommand(factory, argType: .category(path: categoryFolderToImport.path))
        }
    }

    @Test("Saves new Category", arguments: [true, false])
    func savesNewCategory(useArg: Bool) throws {
        let categoryFolderToImport = try tempFolder.createSubfolder(named: "newCategory")
        let path = categoryFolderToImport.path
        let factory = makeContextFactory(categoryFolderToImport: categoryFolderToImport, inputResults: useArg ? [] : [path])
        let context = try factory.makeContext()

        try runCommand(factory, argType: .category(path: useArg ? path : nil))

        let categories = try context.loadCategories()
        let savedCategory = try #require(categories.first)

        #expect(categories.count == 1)
        #expect(savedCategory.name.matches(categoryFolderToImport.name))
        #expect(savedCategory.path.matches(categoryFolderToImport.path))
    }
}


// MARK: - Factory
private extension AddCategoryTests {
    func makeContextFactory(categoryFolderToImport: Folder, inputResults: [String] = [], grantPermission: Bool = true) -> MockContextFactory {
        let selectedDirectory = FilesDirectoryAdapter(folder: categoryFolderToImport)
        let folderBrowser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let picker = MockSwiftPicker(inputResult: .init(type: .ordered(inputResults)), permissionResult: .init(defaultValue: grantPermission))
        
        return .init(picker: picker, folderBrowser: folderBrowser)
    }
}


// MARK: - Run
@MainActor
private func runCommand(_ factory: MockContextFactory? = nil, argType: MainActorBaseAddTests.ArgType) throws {
    try MainActorBaseAddTests.runAddCommand(factory, argType: argType)
}
