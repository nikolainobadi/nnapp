//
//  CreateGroupTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Testing
@testable import nnapp
@preconcurrency import Files

@MainActor
final class CreateGroupTests: MainActorBaseCreateTests {
    private let existingGroupName = "existingGroupName"
    private let existingCategoryName = "existingCategoryName"
    
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])
        
        try super.init(testFolder: .init(name: "addGroupCategoryList", subFolders: [testCategoryFolder]))
    }
}


// MARK: - Unit Tests
extension CreateGroupTests {
    @Test("Throws error when no Category is selected")
    func throwsErrorWhenNoCategorySelected() throws {
        #expect(throws: (any Error).self) {
            try runGroupCommand()
        }
    }
    
    @Test("Throws error when name is taken by existing Group")
    func throwsErrorWhenGroupNameIsTaken() throws {
        let factory = try #require(try makeFactory(includeGroup: true))
        
        #expect(throws: CodeLaunchError.groupNameTaken) {
            try runGroupCommand(factory: factory, name: existingGroupName, category: existingCategoryName)
        }
    }
    
    @Test("Throws error when name is taken by existing folder in Category folder")
    func throwsErrorWhenGroupFolderNameIsTaken() throws {
        let factory = try #require(try makeFactory(includeGroup: false))
        
        #expect(throws: CodeLaunchError.groupFolderAlreadyExists) {
            try runGroupCommand(factory: factory, name: existingGroupName, category: existingCategoryName)
        }
    }
    
    @Test("Creates a new Group folder in an existing Category folder")
    func createsNewGroupFolderInExistingCategoryFolder() throws {
        let groupName = "newGroupName"
        let factory = try #require(try makeFactory())
        
        try runGroupCommand(factory: factory, name: groupName, category: existingCategoryName)
        
        let context = try factory.makeContext()
        let newGroup = try #require(try context.loadGroups().first)
        let newGroupPath = try #require(newGroup.path)
        let updatedCategoryFolder = try #require(try tempFolder.subfolder(named: existingCategoryName))
        let newGroupFolder = try #require(try updatedCategoryFolder.subfolder(named: groupName))
        
        #expect(newGroup.name == groupName)
        #expect(newGroupPath == newGroupFolder.path)
    }
}


// MARK: - Factory
private extension CreateGroupTests {
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



// MARK: - RunCommand
private extension CreateGroupTests {
    func runGroupCommand(factory: MockContextFactory? = nil, name: String? = nil, category: String? = nil) throws {
        try runCommand(factory, argType: .group(name: name, category: category))
    }
}
