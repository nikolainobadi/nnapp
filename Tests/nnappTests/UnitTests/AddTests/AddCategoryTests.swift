//
//  AddCategoryTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
@testable import nnapp

@MainActor
final class AddCategoryTests: MainActorBaseAddTests {
    @Test("Throws an error when the name of imported folder name is taken by an existing Category")
    func throwsErrorWhenFolderNameIsTaken() throws {
        let existingName = "existingCategory"
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        let existingCategory = makeCategory(name: existingName, path: tempFolder.path.appendingPathComponent(existingName))
        let otherFolder = try #require(try tempFolder.createSubfolder(named: "OtherFolder"))
        let categoryFolderToImport = try #require(try otherFolder.createSubfolder(named: existingName))
        
        try context.saveCatgory(existingCategory)
        
        #expect(throws: CodeLaunchError.categoryNameTaken) {
            try runCommand(factory, argType: .category(path: categoryFolderToImport.path))
        }
    }
    
    @Test("Saves new Category", arguments: [true, false])
    func savesNewCategory(useArg: Bool) throws {
        let categoryFolderToImport = try #require(try tempFolder.createSubfolder(named: "newCategory"))
        let path = categoryFolderToImport.path
        let picker = MockPicker(requiredInputResponses: useArg ? [] : [path])
        let factory = MockContextFactory(picker: picker)
        let context = try factory.makeContext()
        
        try runCommand(factory, argType: .category(path: useArg ? path : nil))
        
        let categories = try #require(try context.loadCategories())
        let savedCategory = try #require(categories.first)
        
        #expect(categories.count == 1)
        #expect(savedCategory.name.matches(categoryFolderToImport.name))
        #expect(savedCategory.path.matches(categoryFolderToImport.path))
    }
}
