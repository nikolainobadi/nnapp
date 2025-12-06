//
//  CategoryHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import CodeLaunchKit
import SwiftPickerTesting
import Testing
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

    @Test("Prompts to select category when name missing")
    func promptsToSelectCategoryWhenNameMissing() throws {
        let categories = [
            makeCategory(name: "First"),
            makeCategory(name: "Second")
        ]
        let (sut, store, _) = makeSUT(categories: categories, selectionIndex: 1)

        try sut.removeCategory(named: nil)

        #expect(store.deletedCategories.first?.name == "Second")
    }
}


// MARK: - LaunchGroupCategorySelector
extension CategoryHandlerTests {
    @Test("Select category returns existing match without prompting")
    func selectCategoryReturnsExistingMatchWithoutPrompting() throws {
        let category = makeCategory(name: "Match")
        let (sut, _, _) = makeSUT(categories: [category])

        let selected = try sut.selectCategory(named: "match")

        #expect(selected.name == category.name)
    }
}


// MARK: - SUT
private extension CategoryHandlerTests {
    func makeSUT(
        categories: [LaunchCategory] = [],
        inputResults: [String] = [],
        selectionIndex: Int = 0,
        selectedDirectory: MockDirectory? = MockDirectory(path: "/tmp")
    ) -> (sut: CategoryHandler, store: MockCategoryStore, browser: MockDirectoryBrowser) {
        let store = MockCategoryStore(categories: categories)
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(defaultValue: true, type: .ordered([true])),
            selectionResult: .init(defaultSingle: .index(selectionIndex))
        )
        let browser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let sut = CategoryHandler(store: store, picker: picker, folderBrowser: browser)

        return (sut, store, browser)
    }
}


// MARK: - Mocks
private final class MockCategoryStore: CategoryStore {
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
