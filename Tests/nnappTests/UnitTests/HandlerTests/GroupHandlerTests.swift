//
//  GroupHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 9/2/25.
//

import Darwin
import Testing
import Foundation
@testable import nnapp

@MainActor
final class GroupHandlerTests: MainActorTempFolderDatasource {
    private let importedGroupName = "ImportedGroup"
    private let existingGroupName = "existingGroupName"
    private let existingCategoryName = "existingCategoryName"
    
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])
        
        try super.init(testFolder: .init(name: "GroupHandlerTests", subFolders: [testCategoryFolder]))
    }
}

// MARK: - ImportGroup Tests
extension GroupHandlerTests {
    @Test("Returns a group with the imported folder name")
    func returnsGroupWithCorrectName() throws {
        let (sut, _) = try makeSUT()
        let folder = try tempFolder.createSubfolder(named: importedGroupName)
        let group = try sut.importGroup(path: folder.path, category: existingCategoryName)

        #expect(group.name == importedGroupName)
    }

    @Test("Persists the imported group in storage")
    func persistsImportedGroup() throws {
        let (sut, context) = try makeSUT()
        let folder = try #require(try tempFolder.createSubfolder(named: importedGroupName))

        _ = try sut.importGroup(path: folder.path, category: existingCategoryName)

        let groups = try #require(try context.loadGroups())
        let firstGroup = try #require(groups.first)
        
        #expect(groups.count == 1)
        #expect(firstGroup.name == importedGroupName)
    }

    @Test("Creates a subfolder under the category directory")
    func createsCategorySubfolder() throws {
        let sut = try makeSUT().sut
        let folder = try #require(try tempFolder.createSubfolder(named: importedGroupName))

        _ = try sut.importGroup(path: folder.path, category: existingCategoryName)

        let categoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        
        #expect(categoryFolder.containsSubfolder(named: importedGroupName))
    }

    @Test("Throws error when group name already exists")
    func throwsErrorWhenGroupNameAlreadyExists() throws {
        let (sut, context) = try makeSUT()
        let existingGroup = makeGroup(name: existingGroupName)
        let existingCategory = try #require(try context.loadCategories().first)
        let folderToImport = try tempFolder.createSubfolder(named: existingGroupName)
        
        try context.saveGroup(existingGroup, in: existingCategory)
        
        #expect(throws: CodeLaunchError.groupNameTaken) {
            try sut.importGroup(path: folderToImport.path, category: existingCategoryName)
        }
    }
    
    @Test("Does not move folder when already in correct location")
    func doesNotMoveFolderWhenAlreadyInCorrectLocation() throws {
        let sut = try makeSUT().sut
        let categoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        let groupFolder = try categoryFolder.createSubfolder(named: existingGroupName)
        
        #expect(categoryFolder.containsSubfolder(named: groupFolder.name))
        
        let importedGroup = try sut.importGroup(path: groupFolder.path, category: existingCategoryName)
        
        #expect(importedGroup.name == existingGroupName)
        #expect(categoryFolder.containsSubfolder(named: existingGroupName))
    }
}


// MARK: - Helper Methods
private extension GroupHandlerTests {
    func makeSUT(categoryName: String? = nil, permissionResponses: [Bool] = []) throws -> (sut: GroupHandler, context: CodeLaunchContext) {
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        let existingCategoryFolder = try #require(try tempFolder.createSubfolderIfNeeded(withName: categoryName ?? existingCategoryName))
        let category = makeCategory(name: existingCategoryFolder.name, path: existingCategoryFolder.path)
        
        try context.saveCategory(category)
        
        let mockPicker = MockPicker(permissionResponses: permissionResponses)
        let mockCategorySelector = MockCategorySelector(context: context)
        let sut = GroupHandler(picker: mockPicker, context: context, categorySelector: mockCategorySelector)
        
        return (sut, context)
    }
}
