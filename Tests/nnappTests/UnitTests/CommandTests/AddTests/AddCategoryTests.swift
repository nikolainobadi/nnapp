////
////  AddCategoryTests.swift
////  nnapp
////
////  Created by Nikolai Nobadi on 3/29/25.
////
//
//import Testing
//import CodeLaunchKit
//import SwiftPickerTesting
//@testable import nnapp
//
//@MainActor
//final class AddCategoryTests: MainActorBaseAddTests {
//    @Test("Throws an error when the name of imported folder name is taken by an existing Category")
//    func throwsErrorWhenFolderNameIsTaken() throws {
//        let existingName = "existingCategory"
//        let factory = MockContextFactory()
//        let context = try factory.makeContext()
//        let existingCategory = makeSwiftDataCategory(name: existingName, path: tempFolder.path.appendingPathComponent(existingName))
//        let otherFolder = try tempFolder.createSubfolder(named: "OtherFolder")
//        let categoryFolderToImport = try otherFolder.createSubfolder(named: existingName)
//        
//        try context.saveCategory(existingCategory)
//        
//        do {
//            try runCommand(factory, argType: .category(path: categoryFolderToImport.path))
//        } catch let codeLaunchError as CodeLaunchError {
//            switch codeLaunchError {
//            case .categoryNameTaken:
//                break
//            default:
//                Issue.record("unexpeded error")
//            }
//        }
//    }
//    
//    @Test("Saves new Category", arguments: [true, false])
//    func savesNewCategory(useArg: Bool) throws {
//        let categoryFolderToImport = try tempFolder.createSubfolder(named: "newCategory")
//        let path = categoryFolderToImport.path
//        let picker = MockSwiftPicker(inputResult: .init(type: .ordered(useArg ? [] : [path])))
//        let folderBrowser = MockDirectoryBrowser()
//        folderBrowser.folderToReturn = categoryFolderToImport
//        let factory = MockContextFactory(picker: picker, folderBrowser: folderBrowser)
//        let context = try factory.makeContext()
//        
//        try runCommand(factory, argType: .category(path: useArg ? path : nil))
//        
//        let categories = try context.loadCategories()
//        let savedCategory = try #require(categories.first)
//        
//        #expect(categories.count == 1)
//        #expect(savedCategory.name.matches(categoryFolderToImport.name))
//        #expect(savedCategory.path.matches(categoryFolderToImport.path))
//    }
//}
