//
//  GroupControllerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

struct GroupControllerTests {
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
            permissionResults: [
                false, // Would you like to select a subfolder?
                true // confirm group import
            ],
            directoryToLoad: categoryFolder,
            selectedDirectory: browsedFolder
        )

        let group = try sut.importGroup(path: nil, categoryName: category.name)

        #expect(group.name == browsedFolder.name)
        #expect(store.savedGroups.first?.name == browsedFolder.name)
        #expect(browser.prompt == "Browse to select a folder to import as a Group")
    }

    @Test("Imported group path includes category path")
    func importedGroupPathIncludesCategoryPath() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let groupFolder = MockDirectory(path: "/tmp/NewGroup")
        let (sut, _, _, _) = makeSUT(category: category, directoryToLoad: groupFolder)

        let group = try sut.importGroup(path: groupFolder.path, categoryName: category.name)

        #expect(group.path == "/tmp/cat/NewGroup/")
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
extension GroupControllerTests {
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

    @Test("Created group path includes category path")
    func createdGroupPathIncludesCategoryPath() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let categoryFolder = MockDirectory(path: category.path)
        let (sut, _, _, _) = makeSUT(category: category, directoryToLoad: categoryFolder)

        let group = try sut.createNewGroup(named: "NewGroup", categoryName: category.name)

        #expect(group.path == "/tmp/cat/NewGroup/")
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
extension GroupControllerTests {
    @Test("Removes group by name without prompting")
    func removesGroupByNameWithoutPrompting() throws {
        let groupName = "ToDelete"
        let group = makeGroup(name: groupName)
        let category = makeCategory(name: "TestCat", groups: [group])
        let (sut, store, _, _) = makeSUT(groups: [group], category: category, categoriesToLoad: [category])

        try sut.removeGroup(named: groupName)

        #expect(store.deletedGroups.first?.name == group.name)
    }

    @Test("Removes group using case-insensitive name matching")
    func removesGroupUsingCaseInsensitiveNameMatching() throws {
        let groupName = "MixedCase"
        let group = makeGroup(name: groupName)
        let category = makeCategory(name: "TestCat", groups: [group])
        let (sut, store, _, _) = makeSUT(groups: [group], category: category, categoriesToLoad: [category])

        try sut.removeGroup(named: "mixedcase")

        #expect(store.deletedGroups.first?.name == groupName)
    }

    @Test("Prompts to select group when name missing")
    func promptsToSelectGroupWhenNameMissing() throws {
        let groups = [makeGroup(name: "First"), makeGroup(name: "Second")]
        let category = makeCategory(name: "TestCat", groups: groups)
        let (sut, store, _, _) = makeSUT(
            groups: groups,
            category: category,
            categoriesToLoad: [category],
            treeNavigationOutcome: .child(parentIndex: 0, childIndex: 1)
        )

        try sut.removeGroup(named: nil)

        #expect(store.deletedGroups.first?.name == "Second")
    }

    @Test("Prompts to select group when name not found")
    func promptsToSelectGroupWhenNameNotFound() throws {
        let groups = [makeGroup(name: "First"), makeGroup(name: "Second")]
        let category = makeCategory(name: "TestCat", groups: groups)
        let (sut, store, _, _) = makeSUT(
            groups: groups,
            category: category,
            categoriesToLoad: [category],
            treeNavigationOutcome: .child(parentIndex: 0, childIndex: 0)
        )

        try sut.removeGroup(named: "NonExistent")

        #expect(store.deletedGroups.first?.name == "First")
    }
}


// MARK: - Select Group
extension GroupControllerTests {
    @Test("Returns matching group by name without prompting")
    func returnsMatchingGroupByNameWithoutPrompting() throws {
        let group = makeGroup(name: "Match")
        let category = makeCategory(name: "TestCat", groups: [group])
        let (sut, _, _, _) = makeSUT(groups: [group], category: category, categoriesToLoad: [category])

        let selected = try sut.selectGroup(name: "match")

        #expect(selected.name == group.name)
    }

    @Test("Finds group using case-insensitive matching")
    func findsGroupUsingCaseInsensitiveMatching() throws {
        let group = makeGroup(name: "MixedCase")
        let category = makeCategory(name: "TestCat", groups: [group])
        let (sut, _, _, _) = makeSUT(groups: [group], category: category, categoriesToLoad: [category])

        let selected = try sut.selectGroup(name: "MIXEDCASE")

        #expect(selected.name == "MixedCase")
    }

    @Test("Imports new group when requested name not found")
    func importsNewGroupWhenRequestedNameNotFound() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let groupFolder = MockDirectory(path: "/tmp/imported")
        let (sut, store, _, _) = makeSUT(
            category: category,
            permissionResults: [true, true],
            assignGroupTypeIndex: 2,
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

    @Test("Group created via selectGroup includes category path")
    func groupCreatedViaSelectGroupIncludesCategoryPath() throws {
        let category = makeCategory(name: "TestCat", path: "/tmp/cat")
        let categoryFolder = MockDirectory(path: category.path)
        let (sut, _, _, _) = makeSUT(
            category: category,
            assignGroupTypeIndex: 1,
            directoryToLoad: categoryFolder
        )

        let selected = try sut.selectGroup(name: "NewGroup")

        #expect(selected.path == "/tmp/cat/NewGroup/")
    }

    @Test("Allows choosing from existing groups when name not found")
    func allowsChoosingFromExistingGroupsWhenNameNotFound() throws {
        let existing = makeGroup(name: "Existing")
        let category = makeCategory(name: "TestCat", groups: [existing])
        let (sut, _, _, _) = makeSUT(
            groups: [existing],
            category: category,
            categoriesToLoad: [category],
            assignGroupTypeIndex: 0,
            selectionIndex: 0,
            treeNavigationOutcome: .child(parentIndex: 0, childIndex: 0)
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
            assignGroupTypeIndex: 2,
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
            categoriesToLoad: [category],
            assignGroupTypeIndex: 0,
            selectionIndex: 0,
            treeNavigationOutcome: .child(parentIndex: 0, childIndex: 0)
        )

        let selected = try sut.selectGroup(name: nil)

        #expect(selected.name == "Existing")
    }
}


// MARK: - Set Main Project
extension GroupControllerTests {
    @Test("Clears previous main shortcut when reusing group shortcut")
    func clearsPreviousMainShortcutWhenReusingGroupShortcut() throws {
        let currentMain = makeProject(name: "Main", shortcut: "grp")
        let newMain = makeProject(name: "Alt", shortcut: "alt")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [currentMain, newMain])
        let (sut, store, _, _) = makeSUT(
            groups: [group],
            permissionResults: [true],
            selectionOutcomes: [.index(0)]
        )

        try sut.setMainProject(group: group.name)

        #expect(store.updatedProjects.count == 2)
        #expect(store.updatedProjects.first?.name == currentMain.name)
        #expect(store.updatedProjects.first?.shortcut == nil)
        #expect(store.updatedProjects.last?.name == newMain.name)
        #expect(store.updatedProjects.last?.shortcut == group.shortcut)
        #expect(store.updatedGroups.first?.shortcut == group.shortcut)
    }

    @Test("Uses project shortcut when group shortcut is missing without clearing others")
    func usesProjectShortcutWhenGroupShortcutMissing() throws {
        let current = makeProject(name: "Current", shortcut: "old")
        let newMain = makeProject(name: "New", shortcut: "new")
        let group = makeGroup(name: "Group", shortcut: nil, projects: [current, newMain])
        let (sut, store, _, _) = makeSUT(
            groups: [group],
            selectionOutcomes: [.index(1)]
        )

        try sut.setMainProject(group: group.name)

        #expect(store.updatedProjects.count == 1)
        #expect(store.updatedProjects.first?.name == newMain.name)
        #expect(store.updatedProjects.first?.shortcut == newMain.shortcut)
        #expect(store.updatedGroups.first?.shortcut == newMain.shortcut)
    }

    @Test("Prompts for shortcut when none exist")
    func promptsForShortcutWhenNoneExist() throws {
        let first = makeProject(name: "First", shortcut: nil)
        let second = makeProject(name: "Second", shortcut: nil)
        let group = makeGroup(name: "Group", shortcut: nil, projects: [first, second])
        let expectedShortcut = "custom"
        let (sut, store, _, _) = makeSUT(
            groups: [group],
            inputResults: [expectedShortcut],
            selectionOutcomes: [.index(0)]
        )

        try sut.setMainProject(group: group.name)

        #expect(store.updatedProjects.first?.shortcut == expectedShortcut)
        #expect(store.updatedGroups.first?.shortcut == expectedShortcut)
    }

    @Test("Does nothing when user declines changing existing main project")
    func doesNothingWhenUserDeclinesChangingExistingMainProject() throws {
        let currentMain = makeProject(name: "Main", shortcut: "grp")
        let other = makeProject(name: "Other", shortcut: "alt")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [currentMain, other])
        let (sut, store, _, _) = makeSUT(
            groups: [group],
            permissionResults: [false],
            selectionOutcomes: [.index(0)]
        )

        try sut.setMainProject(group: group.name)

        #expect(store.updatedProjects.isEmpty)
        #expect(store.updatedGroups.isEmpty)
    }
}


// MARK: - SUT
private extension GroupControllerTests {
    func makeSUT(
        groups: [LaunchGroup] = [],
        category: LaunchCategory = makeCategory(),
        categoriesToLoad: [LaunchCategory] = [],
        inputResults: [String] = [],
        permissionResults: [Bool] = [true],
        assignGroupTypeIndex: Int = 0,
        selectionIndex: Int = 0,
        selectionOutcomes: [MockSingleSelectionOutcome]? = nil,
        directoryToLoad: MockDirectory? = MockDirectory(path: "/tmp"),
        selectedDirectory: MockDirectory? = MockDirectory(path: "/tmp"),
        treeNavigationOutcome: MockTreeSelectionOutcome = .none
    ) -> (sut: GroupController, store: MockGroupStore, browser: MockDirectoryBrowser, fileSystem: MockFileSystem) {
        let store = MockGroupStore(groups: groups, category: category, categoriesToLoad: categoriesToLoad)
        let singleSelections = selectionOutcomes ?? [
            .index(assignGroupTypeIndex),
            .index(selectionIndex)
        ]
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(type: .ordered(permissionResults)),
            selectionResult: .init(
                defaultSingle: .index(selectionIndex),
                singleType: .ordered(singleSelections)
            ),
            treeNavigationResult: .init(defaultOutcome: treeNavigationOutcome, type: .ordered([treeNavigationOutcome]))
        )
        let folderBrowser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let categorySelector = MockCategorySelector(category: category)
        let homeDirectory = MockDirectory(path: "/Users/test")
        let categoryDirectory: any Directory
        if let directoryToLoad, directoryToLoad.path == category.path {
            categoryDirectory = directoryToLoad
        } else {
            categoryDirectory = MockDirectory(path: category.path)
        }

        var directoryMap: [String: any Directory] = [
            category.path: categoryDirectory
        ]

        if let directoryToLoad {
            directoryMap[directoryToLoad.path] = directoryToLoad
        }

        let fileSystem = MockFileSystem(homeDirectory: homeDirectory, directoryToLoad: nil, directoryMap: directoryMap)
        let groupService = GroupManager(store: store, fileSystem: fileSystem)
        let sut = GroupController(
            picker: picker,
            fileSystem: fileSystem,
            groupService: groupService,
            folderBrowser: folderBrowser,
            categorySelector: categorySelector
        )

        return (sut, store, folderBrowser, fileSystem)
    }
}


// MARK: - Mocks
private extension GroupControllerTests {
    final class MockGroupStore: LaunchGroupStore {
        private let categoriesToLoad: [LaunchCategory]
        
        private(set) var groups: [LaunchGroup]
        private(set) var savedGroups: [LaunchGroup] = []
        private(set) var deletedGroups: [LaunchGroup] = []
        private(set) var updatedGroups: [LaunchGroup] = []
        private(set) var updatedProjects: [LaunchProject] = []

        let category: LaunchCategory

        init(groups: [LaunchGroup], category: LaunchCategory, categoriesToLoad: [LaunchCategory]) {
            self.groups = groups
            self.category = category
            self.categoriesToLoad = categoriesToLoad
        }

        func loadGroups() throws -> [LaunchGroup] {
            return groups
        }
        
        func loadCategories() throws -> [LaunchCategory] {
            return categoriesToLoad
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
