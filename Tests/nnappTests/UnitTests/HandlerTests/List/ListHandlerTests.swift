//
//  ListHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import CodeLaunchKit
import SwiftPickerTesting
import Testing
@testable import nnapp

struct ListHandlerTests {
    @Test("Displays root placeholder when no categories exist")
    func displaysRootPlaceholderWhenNoCategoriesExist() throws {
        let (sut, _, console) = makeSUT(categories: [])

        try sut.browseHierarchy()

        #expect(console.headers == ["CodeLaunch"])
        #expect(console.lines.contains("No Categories"))
        #expect(console.lines.contains(""))
    }

    @Test("Displays selected category details from tree navigation")
    func displaysSelectedCategoryDetailsFromTreeNavigation() throws {
        let project = makeProject(name: "Proj", shortcut: "pj")
        let group = LaunchGroup.new(name: "Group A", shortcut: "ga", projects: [project])
        let category = LaunchCategory.new(name: "Cat", path: "/tmp/cat", groups: [group])
        let (sut, _, console) = makeSUT(categories: [category], treeNavigationOutcome: .index(0))

        try sut.browseHierarchy()

        #expect(console.headers.contains("Cat"))
        #expect(console.lines.contains(where: { $0.contains("path: /tmp/cat") }))
        #expect(console.lines.contains(where: { $0.contains("group count: 1") }))
        #expect(console.lines.contains(where: { $0.contains("Group A") }))
        #expect(console.lines.contains(where: { $0.contains("Proj") }))
    }
}


// MARK: - Category Operations
extension ListHandlerTests {
    @Test("Selects category by name without prompting")
    func selectsCategoryByNameWithoutPrompting() throws {
        let category = LaunchCategory.new(name: "iOS", path: "/tmp/ios", groups: [])
        let (sut, _, console) = makeSUT(categories: [category])

        try sut.selectAndDisplayCategory(name: "ios")

        #expect(console.headers.filter { $0 == category.name }.count == 2)
        #expect(console.lines.contains(where: { $0.contains("path: /tmp/ios") }))
    }

    @Test("Prompts to select category when name missing")
    func promptsToSelectCategoryWhenNameMissing() throws {
        let categories = [
            LaunchCategory.new(name: "iOS", path: "/tmp/ios", groups: []),
            LaunchCategory.new(name: "Server", path: "/tmp/server", groups: [])
        ]
        let (sut, _, console) = makeSUT(categories: categories, selectionIndex: 1)

        try sut.selectAndDisplayCategory(name: nil)

        #expect(console.headers.contains("Server"))
    }
}


// MARK: - Group Operations
extension ListHandlerTests {
    @Test("Selects group by name without prompting")
    func selectsGroupByNameWithoutPrompting() throws {
        let group = LaunchGroup.new(name: "Backend", shortcut: nil, projects: [])
        let (sut, _, console) = makeSUT(groups: [group])

        try sut.selectAndDisplayGroup(name: "backend")

        #expect(console.headers.filter { $0 == group.name }.count == 2)
        #expect(console.lines.contains(where: { $0.contains("project count: 0") }))
    }

    @Test("Prompts to select group when name missing")
    func promptsToSelectGroupWhenNameMissing() throws {
        let groups = [
            LaunchGroup.new(name: "Backend", shortcut: "be", projects: []),
            LaunchGroup.new(name: "Frontend", shortcut: "fe", projects: [])
        ]
        let (sut, _, console) = makeSUT(groups: groups, selectionIndex: 1)

        try sut.selectAndDisplayGroup(name: nil)

        #expect(console.headers.contains("Frontend"))
    }
}


// MARK: - Project Operations
extension ListHandlerTests {
    @Test("Selects project by name or shortcut without prompting")
    func selectsProjectByNameOrShortcutWithoutPrompting() throws {
        let project = makeProject(name: "CLI", shortcut: "cli", type: .package, remote: nil, links: [], group: nil)
        let (sut, _, console) = makeSUT(projects: [project])

        try sut.selectAndDisplayProject(name: "CLI")

        #expect(console.headers.filter { $0 == project.name }.count == 2)
        #expect(console.lines.contains(where: { $0.contains("project type: Swift Package") }))
        #expect(console.lines.contains(where: { $0.contains("shortcut: cli") }))
    }

    @Test("Prompts to select project when name missing")
    func promptsToSelectProjectWhenNameMissing() throws {
        let projects = [
            makeProject(name: "API", shortcut: "api"),
            makeProject(name: "Web", shortcut: "web")
        ]
        let (sut, _, console) = makeSUT(projects: projects, selectionIndex: 1)

        try sut.selectAndDisplayProject(name: nil)

        #expect(console.headers.contains("Web"))
    }
}


// MARK: - Link Operations
extension ListHandlerTests {
    @Test("Displays placeholder when no project link names exist")
    func displaysPlaceholderWhenNoProjectLinkNamesExist() {
        let (sut, _, console) = makeSUT(linkNames: [])

        sut.displayProjectLinks()

        #expect(console.lines.contains("No saved Project Link names"))
    }

    @Test("Displays project link names when present")
    func displaysProjectLinkNamesWhenPresent() {
        let linkNames = ["Docs", "API"]
        let (sut, _, console) = makeSUT(linkNames: linkNames)

        sut.displayProjectLinks()

        #expect(console.headers == ["Project Link Names"])
        #expect(console.lines.contains("Docs"))
        #expect(console.lines.contains("API"))
    }
}


// MARK: - SUT
private extension ListHandlerTests {
    func makeSUT(
        categories: [LaunchCategory] = [],
        groups: [LaunchGroup] = [],
        projects: [LaunchProject] = [],
        linkNames: [String] = [],
        selectionIndex: Int = 0,
        treeNavigationOutcome: MockTreeSelectionOutcome = .none
    ) -> (sut: ListHandler, loader: StubListLoader, console: MockConsoleOutput) {
        let picker = MockSwiftPicker(
            selectionResult: .init(defaultSingle: .index(selectionIndex)),
            treeNavigationResult: .init(defaultOutcome: treeNavigationOutcome)
        )
        let console = MockConsoleOutput()
        let loader = StubListLoader(categories: categories, groups: groups, projects: projects, linkNames: linkNames)
        let sut = ListHandler(picker: picker, loader: loader, console: console)

        return (sut, loader, console)
    }
}


// MARK: - Mocks
private final class StubListLoader: LaunchListLoader {
    private let categories: [LaunchCategory]
    private let groups: [LaunchGroup]
    private let projects: [LaunchProject]
    private let linkNames: [String]

    init(
        categories: [LaunchCategory],
        groups: [LaunchGroup],
        projects: [LaunchProject],
        linkNames: [String]
    ) {
        self.categories = categories
        self.groups = groups
        self.projects = projects
        self.linkNames = linkNames
    }

    func loadCategories() throws -> [LaunchCategory] {
        return categories
    }

    func loadGroups() throws -> [LaunchGroup] {
        return groups
    }

    func loadProjects() throws -> [LaunchProject] {
        return projects
    }

    func loadProjectLinkNames() -> [String] {
        return linkNames
    }
}
