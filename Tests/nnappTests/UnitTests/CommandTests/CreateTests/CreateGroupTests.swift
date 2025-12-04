//
//  CreateGroupTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Testing
import CodeLaunchKit
@testable import nnapp
@preconcurrency import Files

@MainActor
final class CreateGroupTests: MainActorBaseCreateTests {
    private let existingGroupName = "existingGroupName"
    private let existingCategoryName = "existingCategoryName"
    
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])
        
        try super.init(testFolder: .init(name: "createGroupCategoryList", subFolders: [testCategoryFolder]))
    }
}


// MARK: - Unit Tests
extension CreateGroupTests {
    @Test("Throws error when no Category is selected")
    func throwsErrorWhenNoCategorySelected() {
        do {
            try runGroupCommand()
            Issue.record("expected an error but none were thrown")
        } catch { }
    }
    
    @Test("Throws error when name is taken by existing Group")
    func throwsErrorWhenGroupNameIsTaken() throws {
        let factory = try makeFactory(includeGroup: true)
        
        do {
            try runGroupCommand(factory: factory, name: existingGroupName, category: existingCategoryName)
            Issue.record("expected an error but none were thrown")
        } catch let codeLaunchError as CodeLaunchError {
            switch codeLaunchError {
            case .groupNameTaken:
                break
            default:
                Issue.record("unexpected error")
            }
        }
    }
    
    @Test("Throws error when name is taken by existing folder in Category folder")
    func throwsErrorWhenGroupFolderNameIsTaken() throws {
        let factory = try makeFactory(includeGroup: false)
        
        do {
            try runGroupCommand(factory: factory, name: existingGroupName, category: existingCategoryName)
            Issue.record("expected an error but none were thrown")
        } catch let codeLaunchError as CodeLaunchError {
            switch codeLaunchError {
            case .groupFolderAlreadyExists:
                break
            default:
                Issue.record("unexpected error")
            }
        }
    }
    
    @Test("Creates a new Group folder in an existing Category folder")
    func createsNewGroupFolderInExistingCategoryFolder() throws {
        let groupName = "newGroupName"
        let factory = try makeFactory()

        try runGroupCommand(factory: factory, name: groupName, category: existingCategoryName)

        let context = try factory.makeContext()
        let newGroup = try #require(context.loadGroups().first)
        let newGroupPath = try #require(newGroup.path)
        let updatedCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        let newGroupFolder = try updatedCategoryFolder.subfolder(named: groupName)

        #expect(newGroup.name == groupName)
        #expect(newGroupPath == newGroupFolder.path)
    }
}


// MARK: - Factory
private extension CreateGroupTests {
    func makeFactory(includeGroup: Bool = false) throws -> MockContextFactory {
        let existingCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)
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
