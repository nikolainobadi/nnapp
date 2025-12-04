//
//  ListHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

import Testing
import Foundation
import SwiftPickerTesting
@testable import nnapp

@MainActor
final class ListHandlerTests: MainActorTempFolderDatasource {
    private let existingCategoryName = "TestCategory"
    private let existingGroupName = "TestGroup"
    private let existingProjectName = "TestProject"

    init() throws {
        let testProjectFolder = TestFolder(name: existingProjectName, subFolders: [])
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [testProjectFolder])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])

        try super.init(testFolder: .init(name: "ListHandlerTests", subFolders: [testCategoryFolder]))
    }
}


// MARK: - Browse Hierarchy Tests
extension ListHandlerTests {
    @Test("Displays no categories message when empty")
    func displaysNoCategoriesWhenEmpty() throws {
        let (sut, console, _) = try makeSUT()

        try sut.browseHierarchy()

        #expect(console.headers.contains("CodeLaunch"))
        #expect(console.lines.contains("No Categories"))
    }

    @Test("Displays tree navigation when categories exist")
    func displaysTreeNavigationWhenCategoriesExist() throws {
        let (sut, console, context) = try makeSUT()
        let category = makeCategory(name: "MyCategory", path: tempFolder.path)
        try context.saveCategory(category)

        // Tree navigation will be triggered but won't select anything in tests
        try sut.browseHierarchy()

        // If there are categories, we don't print the "No Categories" message
        #expect(!console.lines.contains("No Categories"))
    }
}


// MARK: - Category Display Tests
extension ListHandlerTests {
    @Test("Displays category details correctly")
    func displaysCategoryDetailsCorrectly() throws {
        let (sut, console, context) = try makeSUT()
        let category = makeCategory(name: "MyCategory", path: tempFolder.path)
        try context.saveCategory(category)

        try sut.selectAndDisplayCategory(name: "MyCategory")

        #expect(console.headers.contains("MyCategory"))
        #expect(console.lines.contains { $0.contains("path:") })
        #expect(console.lines.contains { $0.contains("group count:") })
    }

    @Test("Displays category with groups and projects")
    func displaysCategoryWithGroupsAndProjects() throws {
        let (sut, console, context) = try makeSUT()
        let category = makeCategory(name: "MyCategory", path: tempFolder.path)
        let group = makeGroup(name: "MyGroup", shortcut: "mg")
        let project = makeProject(name: "MyProject", shortcut: "mp")

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        try sut.selectAndDisplayCategory(name: "MyCategory")

        #expect(console.lines.contains { $0.contains("MyGroup") })
        #expect(console.lines.contains { $0.contains("MyProject") })
    }
}


// MARK: - Group Display Tests
extension ListHandlerTests {
    @Test("Displays group details correctly")
    func displaysGroupDetailsCorrectly() throws {
        let (sut, console, context) = try makeSUT()
        let category = makeCategory(name: "MyCategory", path: tempFolder.path)
        let group = makeGroup(name: "MyGroup", shortcut: "mg")

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)

        try sut.selectAndDisplayGroup(name: "MyGroup")

        #expect(console.headers.contains("MyGroup"))
        #expect(console.lines.contains { $0.contains("category: MyCategory") })
        #expect(console.lines.contains { $0.contains("project count:") })
    }

    @Test("Displays group with projects")
    func displaysGroupWithProjects() throws {
        let (sut, console, context) = try makeSUT()
        let category = makeCategory(name: "TestCat", path: tempFolder.path)
        let group = makeGroup(name: "MyGroup", shortcut: "mg")
        let project = makeProject(name: "MyProject", shortcut: "mp")

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        try sut.selectAndDisplayGroup(name: "MyGroup")

        #expect(console.lines.contains { $0.contains("MyProject") })
    }
}


// MARK: - Project Display Tests
extension ListHandlerTests {
    @Test("Displays project details correctly")
    func displaysProjectDetailsCorrectly() throws {
        let (sut, console, context) = try makeSUT()
        let category = makeCategory(name: "TestCat", path: tempFolder.path)
        let group = makeGroup(name: "MyGroup")
        let project = makeProject(name: "MyProject", shortcut: "mp")

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        try sut.selectAndDisplayProject(name: "MyProject")

        #expect(console.headers.contains("MyProject"))
        #expect(console.lines.contains { $0.contains("group: MyGroup") })
        #expect(console.lines.contains { $0.contains("shortcut: mp") })
        #expect(console.lines.contains { $0.contains("project type:") })
    }

    @Test("Displays project with remote repository")
    func displaysProjectWithRemoteRepository() throws {
        let (sut, console, context) = try makeSUT()
        let category = makeCategory(name: "TestCat", path: tempFolder.path)
        let group = makeGroup(name: "MyGroup")
        let remote = SwiftDataProjectLink(name: "origin", urlString: "https://github.com/test/repo.git")
        let project = makeProject(name: "MyProject", remote: remote)

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        try sut.selectAndDisplayProject(name: "MyProject")

        #expect(console.lines.contains { $0.contains("remote repository:") && $0.contains("origin") })
    }
}


// MARK: - Link Display Tests
extension ListHandlerTests {
    @Test("Displays no links message when empty")
    func displaysNoLinksMessageWhenEmpty() throws {
        let (sut, console, _) = try makeSUT()

        sut.displayProjectLinks()

        #expect(console.lines.contains("No saved Project Link names"))
    }

    @Test("Displays link names when available")
    func displaysLinkNamesWhenAvailable() throws {
        let (sut, console, context) = try makeSUT()
        context.saveProjectLinkNames(["Documentation", "API Reference"])

        sut.displayProjectLinks()

        #expect(console.headers.contains("Project Link Names"))
        #expect(console.lines.contains("Documentation"))
        #expect(console.lines.contains("API Reference"))
    }
}


// MARK: - Helper Methods
private extension ListHandlerTests {
    func makeSUT() throws -> (sut: ListHandler, console: MockConsoleOutput, context: CodeLaunchContext) {
        let console = MockConsoleOutput()
        let picker = MockSwiftPicker()
        let context = try MockContextFactory().makeContext()
        let sut = ListHandler(picker: picker, context: context, console: console)

        return (sut, console, context)
    }
}
