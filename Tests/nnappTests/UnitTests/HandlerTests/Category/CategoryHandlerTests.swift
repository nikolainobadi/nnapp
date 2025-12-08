//
//  CategoryHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

struct CategoryHandlerTests {
    @Test("Imports category using provided path")
    func importsCategoryUsingProvidedPath() throws {
        let directory = MockDirectory(path: "/tmp/cat")
        let (sut, store, browser) = makeSUT(selectedDirectory: directory)

        let category = try sut.importCategory(path: directory.path)

        #expect(category.name == directory.name)
        #expect(category.path == directory.path)
        #expect(store.savedCategories.first?.name == directory.name)
        #expect(browser.startPath == directory.path)
    }

    @Test("Imports category by browsing when path is nil")
    func importsCategoryByBrowsingWhenPathIsNil() throws {
        let directory = MockDirectory(path: "/tmp/browsed")
        let (sut, store, browser) = makeSUT(selectedDirectory: directory)

        let category = try sut.importCategory(path: nil)

        #expect(category.name == directory.name)
        #expect(category.path == directory.path)
        #expect(store.savedCategories.first?.name == directory.name)
        #expect(browser.prompt == "Select a folder to import as a Category")
    }

    @Test("Import trims whitespace from category name")
    func importTrimsWhitespaceFromCategoryName() throws {
        let directory = MockDirectory(path: "/tmp/  SpacedName  ")
        let sut = makeSUT(selectedDirectory: directory).sut

        let category = try sut.importCategory(path: directory.path)

        #expect(category.name == "  SpacedName  ".trimmingCharacters(in: .whitespacesAndNewlines))
    }

    @Test("Import throws when name already exists")
    func importThrowsWhenNameAlreadyExists() {
        let existing = makeCategory()
        let directory = MockDirectory(path: existing.path)
        let (sut, _, _) = makeSUT(categories: [existing], selectedDirectory: directory)

        #expect(throws: CodeLaunchError.categoryNameTaken) {
            try sut.importCategory(path: directory.path)
        }
    }
}


// MARK: - Create
extension CategoryHandlerTests {
    @Test("Creates new category with prompted name and parent folder")
    func createsNewCategoryWithPromptedNameAndParentFolder() throws {
        let parent = MockDirectory(path: "/tmp")
        let (sut, store, browser) = makeSUT(
            inputResults: ["NewCat"],
            selectedDirectory: parent
        )

        let category = try sut.createNewCategory(named: nil, parentPath: nil)

        #expect(category.name == "NewCat")
        #expect(category.path == parent.path.appendingPathComponent("NewCat"))
        #expect(store.savedCategories.first?.name == "NewCat")
        #expect(browser.prompt != nil)
    }

    @Test("Creates category using provided name without prompting")
    func createsCategoryUsingProvidedNameWithoutPrompting() throws {
        let parent = MockDirectory(path: "/tmp")
        let (sut, store, _) = makeSUT(selectedDirectory: parent)

        let category = try sut.createNewCategory(named: "ProvidedName", parentPath: nil)

        #expect(category.name == "ProvidedName")
        #expect(store.savedCategories.first?.name == "ProvidedName")
    }

    @Test("Creates category using provided parent path without browsing")
    func createsCategoryUsingProvidedParentPathWithoutBrowsing() throws {
        let parent = MockDirectory(path: "/tmp/provided")
        let (sut, store, browser) = makeSUT(
            inputResults: ["NewCat"],
            selectedDirectory: parent
        )

        let category = try sut.createNewCategory(named: nil, parentPath: parent.path)

        #expect(category.path == parent.path.appendingPathComponent("NewCat"))
        #expect(browser.startPath == parent.path)
        #expect(store.savedCategories.first?.path == category.path)
    }

    @Test("Create trims whitespace from category name")
    func createTrimsWhitespaceFromCategoryName() throws {
        let parent = MockDirectory(path: "/tmp")
        let sut = makeSUT(inputResults: ["  SpacedName  "], selectedDirectory: parent).sut

        let category = try sut.createNewCategory(named: nil, parentPath: nil)

        #expect(category.name == "SpacedName")
    }

    @Test("Create throws when name already exists")
    func createThrowsWhenNameAlreadyExists() {
        let existing = makeCategory(name: "Existing", path: "/tmp/existing")
        let parent = MockDirectory(path: "/tmp")
        let (sut, _, _) = makeSUT(categories: [existing], inputResults: ["Existing"], selectedDirectory: parent)

        #expect(throws: CodeLaunchError.categoryNameTaken) {
            try sut.createNewCategory(named: nil, parentPath: nil)
        }
    }

    @Test("Create throws when parent contains subfolder with same name")
    func createThrowsWhenParentContainsSubfolderWithSameName() {
        let existingName = "existingname"
        let child = MockDirectory(path: "/tmp/\(existingName)")
        let parent = MockDirectory(path: "/tmp", subdirectories: [child])
        let sut = makeSUT(inputResults: [existingName], selectedDirectory: parent).sut

        #expect(throws: CodeLaunchError.categoryPathTaken) {
            try sut.createNewCategory(named: nil, parentPath: nil)
        }
    }
}


// MARK: - Remove
extension CategoryHandlerTests {
    @Test("Removes category by name without prompting")
    func removesCategoryByNameWithoutPrompting() throws {
        let category = makeCategory(name: "ToDelete")
        let (sut, store, _) = makeSUT(categories: [category])

        try sut.removeCategory(named: "ToDelete")

        #expect(store.deletedCategories.first?.name == category.name)
    }

    @Test("Removes category using case-insensitive name matching")
    func removesCategoryUsingCaseInsensitiveNameMatching() throws {
        let category = makeCategory(name: "MixedCase")
        let (sut, store, _) = makeSUT(categories: [category])

        try sut.removeCategory(named: "mixedcase")

        #expect(store.deletedCategories.first?.name == "MixedCase")
    }

    @Test("Prompts to select category when name missing")
    func promptsToSelectCategoryWhenNameMissing() throws {
        let categories = [
            makeCategory(name: "First"),
            makeCategory(name: "Second")
        ]
        let (sut, store, _) = makeSUT(categories: categories, selectionIndex: 0)

        try sut.removeCategory(named: nil)

        #expect(store.deletedCategories.first?.name == "First")
    }

    @Test("Prompts to select category when name not found")
    func promptsToSelectCategoryWhenNameNotFound() throws {
        let categories = [
            makeCategory(name: "First"),
            makeCategory(name: "Second")
        ]
        let (sut, store, _) = makeSUT(categories: categories, selectionIndex: 0)

        try sut.removeCategory(named: "NonExistent")

        #expect(store.deletedCategories.first?.name == "First")
    }
}


// MARK: - Get Category
extension CategoryHandlerTests {
    @Test("Returns category containing the group")
    func returnsCategoryContainingTheGroup() {
        let group = makeGroup(name: "TestGroup")
        let category = makeCategory(name: "Parent", groups: [group])
        let sut = makeSUT(categories: [category]).sut

        let result = sut.getCategory(group: group)

        #expect(result?.name == category.name)
    }

    @Test("Returns nil when no categories exist")
    func returnsNilWhenNoCategoriesExist() {
        let group = makeGroup(name: "Orphan")
        let sut = makeSUT(categories: []).sut

        let result = sut.getCategory(group: group)

        #expect(result == nil)
    }

    @Test("Returns nil when group not found in any category")
    func returnsNilWhenGroupNotFoundInAnyCategory() {
        let group = makeGroup(name: "Orphan")
        let category = makeCategory(name: "Parent", groups: [makeGroup(name: "Different")])
        let sut = makeSUT(categories: [category]).sut

        let result = sut.getCategory(group: group)

        #expect(result == nil)
    }

    @Test("Uses case-insensitive matching when finding group")
    func usesCaseInsensitiveMatchingWhenFindingGroup() {
        let group = makeGroup(name: "MixedCase")
        let category = makeCategory(name: "Parent", groups: [makeGroup(name: "mixedcase")])
        let sut = makeSUT(categories: [category]).sut

        let result = sut.getCategory(group: group)

        #expect(result?.name == category.name)
    }
}


// MARK: - Select Category
extension CategoryHandlerTests {
    @Test("Returns matching category by name without prompting")
    func returnsMatchingCategoryByNameWithoutPrompting() throws {
        let category = makeCategory(name: "Match")
        let (sut, _, _) = makeSUT(categories: [category])

        let selected = try sut.selectCategory(named: "match")

        #expect(selected.name == category.name)
    }

    @Test("Finds category using case-insensitive matching")
    func findsCategoryUsingCaseInsensitiveMatching() throws {
        let category = makeCategory(name: "MixedCase")
        let sut = makeSUT(categories: [category]).sut

        let selected = try sut.selectCategory(named: "MIXEDCASE")

        #expect(selected.name == "MixedCase")
    }

    @Test("Imports new category when requested name not found")
    func importsNewCategoryWhenRequestedNameNotFound() throws {
        let directory = MockDirectory(path: "/tmp/imported")
        let (sut, store, _) = makeSUT(
            categories: [],
            assignCategoryTypeIndex: 0,
            selectedDirectory: directory
        )

        let selected = try sut.selectCategory(named: "NotFound")

        #expect(selected.name == directory.name)
        #expect(store.savedCategories.first?.name == directory.name)
    }

    @Test("Creates new category using provided name when not found")
    func createsNewCategoryUsingProvidedNameWhenNotFound() throws {
        let parent = MockDirectory(path: "/tmp")
        let (sut, store, _) = makeSUT(
            categories: [],
            assignCategoryTypeIndex: 1,
            selectedDirectory: parent
        )

        let selected = try sut.selectCategory(named: "NotFound")

        #expect(selected.name == "NotFound")
        #expect(store.savedCategories.first?.name == "NotFound")
    }

    @Test("Allows choosing from existing categories when name not found")
    func allowsChoosingFromExistingCategoriesWhenNameNotFound() throws {
        let existing = makeCategory(name: "Existing")
        let (sut, _, _) = makeSUT(
            categories: [existing],
            assignCategoryTypeIndex: 2,
            selectionIndex: 0
        )

        let selected = try sut.selectCategory(named: "NotFound")

        #expect(selected.name == "Existing")
    }

    @Test("Imports category when no name provided and import chosen")
    func importsCategoryWhenNoNameProvidedAndImportChosen() throws {
        let directory = MockDirectory(path: "/tmp/imported")
        let (sut, store, _) = makeSUT(
            categories: [],
            assignCategoryTypeIndex: 0,
            selectedDirectory: directory
        )

        let selected = try sut.selectCategory(named: nil)

        #expect(selected.name == directory.name)
        #expect(store.savedCategories.first?.name == directory.name)
    }

    @Test("Creates category with prompted name when no name provided")
    func createsCategoryWithPromptedNameWhenNoNameProvided() throws {
        let parent = MockDirectory(path: "/tmp")
        let (sut, store, _) = makeSUT(
            categories: [],
            inputResults: ["NewCategory"],
            assignCategoryTypeIndex: 1,
            selectedDirectory: parent
        )

        let selected = try sut.selectCategory(named: nil)

        #expect(selected.name == "NewCategory")
        #expect(store.savedCategories.first?.name == "NewCategory")
    }

    @Test("Allows choosing from existing categories when no name provided")
    func allowsChoosingFromExistingCategoriesWhenNoNameProvided() throws {
        let existing = makeCategory(name: "Existing")
        let (sut, _, _) = makeSUT(
            categories: [existing],
            assignCategoryTypeIndex: 2,
            selectionIndex: 0
        )

        let selected = try sut.selectCategory(named: nil)

        #expect(selected.name == "Existing")
    }
}


// MARK: - SUT
private extension CategoryHandlerTests {
    func makeSUT(
        categories: [LaunchCategory] = [],
        inputResults: [String] = [],
        assignCategoryTypeIndex: Int = 0,
        selectionIndex: Int = 0,
        selectedDirectory: MockDirectory? = MockDirectory(path: "/tmp")
    ) -> (sut: CategoryHandler, store: MockCategoryStore, browser: MockDirectoryBrowser) {
        let store = MockCategoryStore(categories: categories)
        let manager = CategoryManager(store: store)
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(defaultValue: true, type: .ordered([true])),
            selectionResult: .init(
                defaultSingle: .index(selectionIndex),
                singleType: .ordered([
                    .index(assignCategoryTypeIndex),
                    .index(selectionIndex)
                ])
            )
        )
        let browser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let sut = CategoryHandler(manager: manager, picker: picker, folderBrowser: browser)

        return (sut, store, browser)
    }
}


// MARK: - Mocks
private extension CategoryHandlerTests {
    final class MockCategoryStore: CategoryStore {
        private(set) var categories: [LaunchCategory]
        private(set) var savedCategories: [LaunchCategory] = []
        private(set) var deletedCategories: [LaunchCategory] = []
        
        init(categories: [LaunchCategory]) {
            self.categories = categories
        }
        
        func loadCategories() throws -> [LaunchCategory] {
            return categories
        }
        
        func saveCategory(_ category: LaunchCategory) throws {
            savedCategories.append(category)
            categories.append(category)
        }
        
        func deleteCategory(_ category: LaunchCategory) throws {
            deletedCategories.append(category)
        }
    }
}
