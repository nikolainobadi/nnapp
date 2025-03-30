//
//  AddGroupTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
@testable import nnapp

@MainActor
final class AddGroupTests: MainActorBaseAddTests {
    private let existingGroupName = "existingGroupName"
    private let existingCategoryName = "existingCategoryName"
    
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])
        
        try super.init(testFolder: .init(name: "addGroupCategoryList", subFolders: [testCategoryFolder]))
    }
}


// MARK: -
extension AddGroupTests {
    @Test("Existing Category Folder exists with existing Group Folder")
    func startingValues() throws {
        let existingCategoryFolder = try #require(try tempFolder.subfolder(named: existingCategoryName))
        
        #expect(existingCategoryFolder.containsSubfolder(named: existingGroupName))
    }
    
    @Test("Throws error when no category is selected")
    func throwsErrorWhenNoCategorySelected() {
        #expect(throws: (any Error).self) {
            try runGroupCommand()
        }
    }
    
    @Test("Throws an error when Group name already exists in Category")
    func throwsErrorWhenGroupNameIsTaken() throws {
        let factory = try #require(try makeFactory(includeGroup: true))
        let folderToImport = try #require(try tempFolder.createSubfolder(named: existingGroupName))
        
        #expect(throws: CodeLaunchError.groupNameTaken) {
            try runGroupCommand(factory, path: folderToImport.path)
        }
    }
    
    @Test("Throws an error when Group folder name already exists in Category Folder")
    func throwsErrorWhenGroupFolderNameIsTaken() throws {
        let factory = try #require(try makeFactory())
        let folderToImport = try #require(try tempFolder.createSubfolder(named: existingGroupName))
        
        #expect(throws: CodeLaunchError.groupFolderAlreadyExists) {
            try runGroupCommand(factory, path: folderToImport.path)
        }
    }
    
    @Test("Moves imported Group folder to Category Folder")
    func movesGroupFolderToCategoryFolder() throws {
        let factory = try #require(try makeFactory())
        let folderToImport = try #require(try tempFolder.createSubfolder(named: "newGroupName"))
        
        try runGroupCommand(factory, path: folderToImport.path, category: existingCategoryName)
        
        let existingCategoryFolder = try #require(try tempFolder.subfolder(named: existingCategoryName))
        
        #expect(existingCategoryFolder.subfolders.count() == 2)
        #expect(existingCategoryFolder.containsSubfolder(named: folderToImport.name))
        
    }
    
    @Test("Does not move imported Group folder to Category Folder when it is already there")
    func doesNotMoveGroupFolderToCategoryFolderWhenAlreadyThere() throws {
        let factory = try #require(try makeFactory())
        let existingCategoryFolder = try #require(try tempFolder.subfolder(named: existingCategoryName))
        let folderToImport = try #require(try existingCategoryFolder.createSubfolder(named: "newGroupName"))
        
        #expect(existingCategoryFolder.subfolders.count() == 2)
        
        try runGroupCommand(factory, path: folderToImport.path, category: folderToImport.name)
        
        let updatedCategoryFolder = try #require(try tempFolder.subfolder(named: existingCategoryName))
        
        #expect(updatedCategoryFolder.subfolders.count() == 2)
        #expect(updatedCategoryFolder.containsSubfolder(named: folderToImport.name))
    }
    
    @Test("Saves new Group to Category")
    func savesNewGroupToCategory() throws {
        let factory = try #require(try makeFactory())
        let context = try factory.makeContext()
        let groups = try context.loadGroups()
        let existingCategoryFolder = try #require(try tempFolder.subfolder(named: existingCategoryName))
        let folderToImport = try #require(try existingCategoryFolder.createSubfolder(named: "newGroupName"))
        
        #expect(groups.isEmpty)
        
        try runGroupCommand(factory, path: folderToImport.path, category: folderToImport.name)
        
        let updatedGroups = try context.loadGroups()
        
        #expect(updatedGroups.count == 1)
    }
}


// MARK: - Factory
private extension AddGroupTests {
    func makeFactory(includeGroup: Bool = false) throws -> MockContextFactory {
        let existingCategoryFolder = try #require(try tempFolder.subfolder(named: existingCategoryName))
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        let category = makeCategory(name: existingCategoryName, path: existingCategoryFolder.path)
        try context.saveCategory(category)
        
        if includeGroup {
            try context.saveGroup(makeGroup(name: existingGroupName), in: category)
        }
        
        return factory
    }
}


// MARK: - Run Command
private extension AddGroupTests {
    func runGroupCommand(_ factory: MockContextFactory? = nil, path: String? = nil, category: String? = nil) throws {
        try runCommand(factory, argType: .group(path: path, category: category))
    }
}
