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
    @Test("Throws an error when the name of imported folder name is taken by an existing Category")
    func throwsErrorWhenFolderNameIsTaken() throws {
        let existingName = "existingCategory"
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        let existingCategory = makeCategory(name: existingName, path: categoryListFolder.path.appendingPathComponent(existingName))
        let otherFolder = try #require(try categoryListFolder.createSubfolder(named: "OtherFolder"))
        let categoryFolderToImport = try #require(try otherFolder.createSubfolder(named: existingName))
        
        try context.saveCatgory(existingCategory)
        
        #expect(throws: CodeLaunchError.categoryNameTaken) {
            try runCommand(factory, argType: .category(path: categoryFolderToImport.path))
        }
    }
    
    @Test("Saves new Category", arguments: [false, true])
    func savesNewCategory(useArg: Bool) throws {
        let categoryFolderToImport = try #require(try categoryListFolder.createSubfolder(named: "newCategory"))
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


// MARK: - Group Tests
extension AddTests {
    @Test("Throws an error when Group name already exists in Category")
    func throwsErrorWhenGroupNameIsTaken() {
        // TODO: -
    }
    
    @Test("Throws an error when Group folder name already exists in Category Folder")
    func throwsErrorWhenGroupFolderNameIsTaken() {
        // TODO: -
    }
    
    @Test("Moves imported Group folder to Category Folder")
    func movesGroupFolderToCategoryFolder() throws {
        // TODO: -
    }
    
    @Test("Does not move imported Group folder to Category Folder when it is already there")
    func doesNotMoveGroupFolderToCategoryFolderWhenAlreadyThere() throws {
        // TODO: -
    }
    
    @Test("Saves new Group to Category")
    func savesNewGroupToCategory() throws {
        // TODO: -
    }
}


// MARK: - Project Tests
extension AddTests {
    @Test("Throws an error if no group is selected")
    func throwsErrorWhenNoGroupSelected() throws {
        // TODO: -
    }
    
    @Test("Throws error if path from arg finds folder without a project type.")
    func throwsErrorWhenNoProjecTypeExists() {
        // TODO: -
    }
    
    @Test("Throws error if no project path is input")
    func throwsErrorWhenNoPathInputIsProvided() {
        // TODO: -
    }
    
    @Test("Throws error if Project name is taken")
    func throwsErrorWhenProjectNameTaken() {
        // TODO: -
    }
    
    @Test("Throws error if Project shortcut is taken")
    func throwsErrorWhenProjectShortcutTaken() {
        // TODO: -
    }
    
    @Test("Moves Project folder to Group folder when necessary")
    func movesProjectFolderWhenNecessary() {
        // TODO: -
    }
    
    @Test("Does not move Project folder to Group folder if it is already there")
    func doesNotMoveProjectFolderWhenAlreadyInGroupFolder() {
        // TODO: -
    }
    
    @Test("Saves new Project to selected Group")
    func savesNewProjectToGroup() {
        // TODO: -
    }
}


// MARK: - RunCommand
private extension AddTests {
    func runCommand(_ factory: MockContextFactory? = nil, argType: ArgType) throws {
        var args = ["add"]
        
        switch argType {
        case .category(let path):
            args.append("category")
            
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
