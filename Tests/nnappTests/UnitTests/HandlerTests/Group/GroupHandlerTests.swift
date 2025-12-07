//
//  GroupHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

struct GroupHandlerTests {
    @Test("Imports group using provided path")
    func importsGroupUsingProvidedPath() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let groupFolder = MockDirectory(path: "/tmp/group")
        let (sut, store, _, fileSystem) = makeSUT(category: category, directoryToLoad: groupFolder)

        let group = try sut.importGroup(path: groupFolder.path, categoryName: category.name)

        #expect(group.name == groupFolder.name)
        #expect(store.savedGroups.first?.name == groupFolder.name)
        #expect(fileSystem.capturedPaths.contains(groupFolder.path))
    }

    @Test("Imports group by browsing when path is nil")
    func importsGroupByBrowsingWhenPathIsNil() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let groupFolder = MockDirectory(path: "/tmp/browsed")
        let (sut, store, browser, _) = makeSUT(
            category: category,
            directoryToLoad: groupFolder,
            selectedDirectory: groupFolder
        )

        let group = try sut.importGroup(path: nil, categoryName: category.name)

        #expect(group.name == groupFolder.name)
        #expect(store.savedGroups.first?.name == groupFolder.name)
        #expect(browser.prompt == "Browse to select a folder to import as a Group")
    }


    @Test("Browses for folder when user declines category subdirectory")
    func browsesForFolderWhenUserDeclinesCategorySubdirectory() throws {
        let subfolder = MockDirectory(path: "/tmp/cat/subfolder")
        let categoryFolder = MockDirectory(path: "/tmp/cat", subdirectories: [subfolder])
        let category = makeCategory(name: "TestCat", path: categoryFolder.path)
        let browsedFolder = MockDirectory(path: "/tmp/elsewhere")
        let (sut, store, browser, _) = makeSUT(
            category: category,
            permissionResults: [false],
            directoryToLoad: categoryFolder,
            selectedDirectory: browsedFolder
        )

        let group = try sut.importGroup(path: nil, categoryName: category.name)

        #expect(group.name == browsedFolder.name)
        #expect(store.savedGroups.first?.name == browsedFolder.name)
        #expect(browser.prompt == "Browse to select a folder to import as a Group")
    }

    @Test("Import throws when group name already exists")
    func importThrowsWhenGroupNameAlreadyExists() {
        let existing = makeGroup(name: "Existing")
        let category = makeCategory(name: "TestCat", path: "/tmp/cat", groups: [existing])
        let groupFolder = MockDirectory(path: "/tmp/Existing")
        let (sut, _, _, _) = makeSUT(category: category, directoryToLoad: groupFolder)

        #expect(throws: CodeLaunchError.groupNameTaken) {
            try sut.importGroup(path: groupFolder.path, categoryName: category.name)
        }
    }

}


// MARK: - Create
extension GroupHandlerTests {
    @Test("Creates new group with prompted name")
    func createsNewGroupWithPromptedName() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let categoryFolder = MockDirectory(path: category.path)
        let (sut, store, _, _) = makeSUT(
            category: category,
            inputResults: ["NewGroup"],
            directoryToLoad: categoryFolder
        )

        let group = try sut.createNewGroup(named: nil, categoryName: category.name)

        #expect(group.name == "NewGroup")
        #expect(store.savedGroups.first?.name == "NewGroup")
    }

    @Test("Creates group using provided name without prompting")
    func createsGroupUsingProvidedNameWithoutPrompting() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let categoryFolder = MockDirectory(path: category.path)
        let (sut, store, _, _) = makeSUT(category: category, directoryToLoad: categoryFolder)

        let group = try sut.createNewGroup(named: "ProvidedName", categoryName: category.name)

        #expect(group.name == "ProvidedName")
        #expect(store.savedGroups.first?.name == "ProvidedName")
    }

    @Test("Create throws when group name already exists")
    func createThrowsWhenGroupNameAlreadyExists() {
        let existing = makeGroup(name: "Existing")
        let category = makeCategory(name: "TestCat", path: "/tmp/cat", groups: [existing])
        let categoryFolder = MockDirectory(path: category.path)
        let (sut, _, _, _) = makeSUT(category: category, directoryToLoad: categoryFolder)

        #expect(throws: CodeLaunchError.groupNameTaken) {
            try sut.createNewGroup(named: "Existing", categoryName: category.name)
        }
    }

    @Test("Create throws when group folder already exists in category")
    func createThrowsWhenGroupFolderAlreadyExistsInCategory() {
        let existingSubfolder = MockDirectory(path: "/tmp/cat/NewGroup")
        let categoryFolder = MockDirectory(path: "/tmp/cat", subdirectories: [existingSubfolder])
        let category = makeCategory(name: "TestCat", path: categoryFolder.path)
        let (sut, _, _, _) = makeSUT(category: category, directoryToLoad: categoryFolder)

        #expect(throws: CodeLaunchError.groupFolderAlreadyExists) {
            try sut.createNewGroup(named: "NewGroup", categoryName: category.name)
        }
    }
}


// MARK: - Remove
extension GroupHandlerTests {
    @Test("Removes group by name without prompting")
    func removesGroupByNameWithoutPrompting() throws {
        let group = makeGroup(name: "ToDelete")
        let category = makeCategory(name: "TestCat", groups: [group])
        let (sut, store, _, _) = makeSUT(groups: [group], category: category)

        try sut.removeGroup(named: "ToDelete")

        #expect(store.deletedGroups.first?.name == group.name)
    }

    @Test("Removes group using case-insensitive name matching")
    func removesGroupUsingCaseInsensitiveNameMatching() throws {
        let group = makeGroup(name: "MixedCase")
        let category = makeCategory(name: "TestCat", groups: [group])
        let (sut, store, _, _) = makeSUT(groups: [group], category: category)

        try sut.removeGroup(named: "mixedcase")

        #expect(store.deletedGroups.first?.name == "MixedCase")
    }

    @Test("Prompts to select group when name missing")
    func promptsToSelectGroupWhenNameMissing() throws {
        let groups = [makeGroup(name: "First"), makeGroup(name: "Second")]
        let category = makeCategory(name: "TestCat", groups: groups)
        let (sut, store, _, _) = makeSUT(groups: groups, category: category, assignGroupTypeIndex: 1, selectionIndex: 0)

        try sut.removeGroup(named: nil)

        #expect(store.deletedGroups.first?.name == "Second")
    }

    @Test("Prompts to select group when name not found")
    func promptsToSelectGroupWhenNameNotFound() throws {
        let groups = [makeGroup(name: "First"), makeGroup(name: "Second")]
        let category = makeCategory(name: "TestCat", groups: groups)
        let (sut, store, _, _) = makeSUT(groups: groups, category: category, selectionIndex: 0)

        try sut.removeGroup(named: "NonExistent")

        #expect(store.deletedGroups.first?.name == "First")
    }
}


// MARK: - Select Group
extension GroupHandlerTests {
    @Test("Returns matching group by name without prompting")
    func returnsMatchingGroupByNameWithoutPrompting() throws {
        let group = makeGroup(name: "Match")
        let category = makeCategory(name: "TestCat", groups: [group])
        let (sut, _, _, _) = makeSUT(groups: [group], category: category)

        let selected = try sut.selectGroup(name: "match")

        #expect(selected.name == group.name)
    }

    @Test("Finds group using case-insensitive matching")
    func findsGroupUsingCaseInsensitiveMatching() throws {
        let group = makeGroup(name: "MixedCase")
        let category = makeCategory(name: "TestCat", groups: [group])
        let (sut, _, _, _) = makeSUT(groups: [group], category: category)

        let selected = try sut.selectGroup(name: "MIXEDCASE")

        #expect(selected.name == "MixedCase")
    }

    @Test("Imports new group when requested name not found")
    func importsNewGroupWhenRequestedNameNotFound() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let groupFolder = MockDirectory(path: "/tmp/imported")
        let (sut, store, _, _) = makeSUT(
            category: category,
            assignGroupTypeIndex: 0,
            directoryToLoad: groupFolder,
            selectedDirectory: groupFolder
        )

        let selected = try sut.selectGroup(name: "NotFound")

        #expect(selected.name == groupFolder.name)
        #expect(store.savedGroups.first?.name == groupFolder.name)
    }

    @Test("Creates new group using provided name when not found")
    func createsNewGroupUsingProvidedNameWhenNotFound() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let categoryFolder = MockDirectory(path: category.path)
        let (sut, store, _, _) = makeSUT(
            category: category,
            assignGroupTypeIndex: 1,
            directoryToLoad: categoryFolder
        )

        let selected = try sut.selectGroup(name: "NotFound")

        #expect(selected.name == "NotFound")
        #expect(store.savedGroups.first?.name == "NotFound")
    }

    @Test("Allows choosing from existing groups when name not found")
    func allowsChoosingFromExistingGroupsWhenNameNotFound() throws {
        let existing = makeGroup(name: "Existing")
        let category = makeCategory(name: "TestCat", groups: [existing])
        let (sut, _, _, _) = makeSUT(
            groups: [existing],
            category: category,
            assignGroupTypeIndex: 2,
            selectionIndex: 0
        )

        let selected = try sut.selectGroup(name: "NotFound")

        #expect(selected.name == "Existing")
    }

    @Test("Imports group when no name provided and import chosen")
    func importsGroupWhenNoNameProvidedAndImportChosen() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let groupFolder = MockDirectory(path: "/tmp/imported")
        let (sut, store, _, _) = makeSUT(
            category: category,
            assignGroupTypeIndex: 0,
            directoryToLoad: groupFolder,
            selectedDirectory: groupFolder
        )

        let selected = try sut.selectGroup(name: nil)

        #expect(selected.name == groupFolder.name)
        #expect(store.savedGroups.first?.name == groupFolder.name)
    }

    @Test("Creates group with prompted name when no name provided")
    func createsGroupWithPromptedNameWhenNoNameProvided() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let categoryFolder = MockDirectory(path: category.path)
        let (sut, store, _, _) = makeSUT(
            category: category,
            inputResults: ["NewGroup"],
            assignGroupTypeIndex: 1,
            directoryToLoad: categoryFolder
        )

        let selected = try sut.selectGroup(name: nil)

        #expect(selected.name == "NewGroup")
        #expect(store.savedGroups.first?.name == "NewGroup")
    }

    @Test("Allows choosing from existing groups when no name provided")
    func allowsChoosingFromExistingGroupsWhenNoNameProvided() throws {
        let existing = makeGroup(name: "Existing")
        let category = makeCategory(name: "TestCat", groups: [existing])
        let (sut, _, _, _) = makeSUT(
            groups: [existing],
            category: category,
            assignGroupTypeIndex: 2,
            selectionIndex: 0
        )

        let selected = try sut.selectGroup(name: nil)

        #expect(selected.name == "Existing")
    }
}


// MARK: - SUT
private extension GroupHandlerTests {
    func makeSUT(
        groups: [LaunchGroup] = [],
        category: LaunchCategory = makeCategory(),
        inputResults: [String] = [],
        permissionResults: [Bool] = [true],
        assignGroupTypeIndex: Int = 0,
        selectionIndex: Int = 0,
        directoryToLoad: MockDirectory? = MockDirectory(path: "/tmp"),
        selectedDirectory: MockDirectory? = MockDirectory(path: "/tmp")
    ) -> (sut: GroupHandler, store: MockGroupStore, browser: MockDirectoryBrowser, fileSystem: MockFileSystem) {
        let store = MockGroupStore(groups: groups, category: category)
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(type: .ordered(permissionResults)),
            selectionResult: .init(
                defaultSingle: .index(selectionIndex),
                singleType: .ordered([
                    .index(assignGroupTypeIndex),
                    .index(selectionIndex)
                ])
            )
        )
        let browser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let categorySelector = MockCategorySelector(category: category)
        let homeDirectory = MockDirectory(path: "/Users/test")
        let fileSystem = MockFileSystem(homeDirectory: homeDirectory, directoryToLoad: directoryToLoad)
        let sut = GroupHandler(
            store: store,
            picker: picker,
            folderBrowser: browser,
            categorySelector: categorySelector,
            fileSystem: fileSystem
        )

        return (sut, store, browser, fileSystem)
    }
}


// MARK: - Mocks
private extension GroupHandlerTests {
    final class MockGroupStore: LaunchGroupStore {
        private(set) var groups: [LaunchGroup]
        private(set) var savedGroups: [LaunchGroup] = []
        private(set) var deletedGroups: [LaunchGroup] = []
        private(set) var updatedGroups: [LaunchGroup] = []
        private(set) var updatedProjects: [LaunchProject] = []

        let category: LaunchCategory

        init(groups: [LaunchGroup], category: LaunchCategory) {
            self.groups = groups
            self.category = category
        }

        func loadGroups() throws -> [LaunchGroup] {
            return groups
        }

        func saveGroup(_ group: LaunchGroup, in category: LaunchCategory) throws {
            savedGroups.append(group)
            groups.append(group)
        }

        func updateGroup(_ group: LaunchGroup) throws {
            updatedGroups.append(group)
        }

        func deleteGroup(_ group: LaunchGroup) throws {
            deletedGroups.append(group)
        }

        func updateProject(_ project: LaunchProject) throws {
            updatedProjects.append(project)
        }
    }

    final class MockCategorySelector: LaunchGroupCategorySelector {
        let category: LaunchCategory

        init(category: LaunchCategory) {
            self.category = category
        }

        func getCategory(group: LaunchGroup) -> LaunchCategory? {
            return category
        }

        func selectCategory(named name: String?) throws -> LaunchCategory {
            return category
        }
    }
}
