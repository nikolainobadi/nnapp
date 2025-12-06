//
//  FinderHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import CodeLaunchKit
import SwiftPickerTesting
import Testing
@testable import nnapp

struct FinderHandlerTests {
    @Test("Browse all prints placeholder when no categories exist")
    func browseAllPrintsPlaceholderWhenNoCategoriesExist() throws {
        let (sut, picker, shell, console) = makeSUT(categories: [])

        try sut.browseAll()

        #expect(console.lines.contains("No categories found. Create a category first."))
        #expect(picker.capturedTreeNavigationPrompts.isEmpty)
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Browse all prints message when selection is nil")
    func browseAllPrintsMessageWhenSelectionIsNil() throws {
        let category = LaunchCategory.new(name: "Cat", path: "/tmp/cat", groups: [])
        let (sut, picker, shell, console) = makeSUT(
            categories: [category],
            treeNavigationOutcome: .none
        )

        try sut.browseAll()

        #expect(picker.capturedTreeNavigationPrompts == ["Browse and select folder to open"])
        #expect(console.lines.contains("No selection made."))
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Browse all opens selected path")
    func browseAllOpensSelectedPath() throws {
        let category = LaunchCategory.new(name: "Cat", path: "/tmp/cat", groups: [])
        let (sut, picker, shell, _) = makeSUT(
            categories: [category],
            treeNavigationOutcome: .index(0)
        )

        try sut.browseAll()

        #expect(picker.capturedTreeNavigationPrompts == ["Browse and select folder to open"])
        #expect(shell.executedCommand(containing: "open -a Finder /tmp/cat"))
    }
}


// MARK: - Category
extension FinderHandlerTests {
    @Test("Open category uses direct match without prompts")
    func openCategoryUsesDirectMatchWithoutPrompts() throws {
        let category = LaunchCategory.new(name: "iOS", path: "/tmp/ios", groups: [])
        let (sut, picker, shell, _) = makeSUT(categories: [category])

        try sut.openCategory(name: "ios")

        #expect(picker.capturedSingleSelectionPrompts.isEmpty)
        #expect(shell.executedCommand(containing: "/tmp/ios"))
    }

    @Test("Open category prompts when name missing")
    func openCategoryPromptsWhenNameMissing() throws {
        let categories = [
            LaunchCategory.new(name: "iOS", path: "/tmp/ios", groups: []),
            LaunchCategory.new(name: "Server", path: "/tmp/server", groups: [])
        ]
        let (sut, picker, shell, _) = makeSUT(categories: categories, selectionIndex: 1)

        try sut.openCategory(name: nil)

        #expect(picker.capturedSingleSelectionPrompts == ["Select a Category"])
        #expect(shell.executedCommand(containing: "/tmp/server"))
    }
}


// MARK: - Group
extension FinderHandlerTests {
    @Test("Open group uses direct match without prompts", .disabled())
    func openGroupUsesDirectMatchWithoutPrompts() throws {
        let group = LaunchGroup.new(name: "Backend", shortcut: "be", projects: [])
        let category = LaunchCategory.new(name: "Cat", path: "/tmp/cat", groups: [group])
        let (sut, picker, shell, _) = makeSUT(categories: [category], groups: [group])

        try sut.openGroup(name: "BE")

        #expect(picker.capturedSingleSelectionPrompts.isEmpty)
        #expect(shell.executedCommand(containing: try #require(group.path)))
    }

    @Test("Open group prompts then selects when name missing", .disabled())
    func openGroupPromptsThenSelectsWhenNameMissing() throws {
        let groups = [
            LaunchGroup.new(name: "Backend", shortcut: "be", projects: []),
            LaunchGroup.new(name: "Frontend", shortcut: "fe", projects: [])
        ]
        let (sut, picker, shell, _) = makeSUT(groups: groups, selectionIndex: 1)

        try sut.openGroup(name: nil)

        #expect(picker.capturedSingleSelectionPrompts == ["Select a Group"])
        #expect(shell.executedCommand(containing: try #require(groups[1].path)))
    }

    @Test("Open group throws when selected group has no path")
    func openGroupThrowsWhenSelectedGroupHasNoPath() {
        let groups = [
            LaunchGroup.new(name: "Backend", shortcut: "be", projects: []),
            LaunchGroup.new(name: "Frontend", shortcut: "fe", projects: [])
        ]
        let (sut, picker, shell, console) = makeSUT(groups: groups, selectionIndex: 0)

        #expect(throws: CodeLaunchError.missingGroup) {
            try sut.openGroup(name: nil)
        }
        #expect(picker.capturedSingleSelectionPrompts == ["Select a Group"])
        #expect(console.lines.contains(where: { $0.contains("Could not resolve local path for Backend") }))
        #expect(shell.executedCommands.isEmpty)
    }
}


// MARK: - Project
extension FinderHandlerTests {
    @Test("Open project uses direct match without prompts")
    func openProjectUsesDirectMatchWithoutPrompts() throws {
        let group = makeProjectGroup(path: "/tmp/group")
        let project = makeProject(name: "API", shortcut: "api", group: group)
        let (sut, picker, shell, _) = makeSUT(projects: [project])

        try sut.openProject(name: "API")

        let path = try #require(project.folderPath)
        #expect(picker.capturedSingleSelectionPrompts.isEmpty)
        #expect(shell.executedCommand(containing: path))
    }

    @Test("Open project prompts then selects when name missing")
    func openProjectPromptsThenSelectsWhenNameMissing() throws {
        let group = makeProjectGroup(path: "/tmp/group")
        let projects = [
            makeProject(name: "API", shortcut: "api", group: group),
            makeProject(name: "Web", shortcut: "web", group: group)
        ]
        let (sut, picker, shell, _) = makeSUT(projects: projects, selectionIndex: 1)

        try sut.openProject(name: nil)

        let selectedPath = try #require(projects[1].folderPath)
        #expect(picker.capturedSingleSelectionPrompts == ["Select a Project"])
        #expect(shell.executedCommand(containing: selectedPath))
    }

    @Test("Open project throws when selected project has no path")
    func openProjectThrowsWhenSelectedProjectHasNoPath() {
        let projects = [makeProject(name: "Broken", shortcut: "brk", group: nil)]
        let (sut, picker, shell, console) = makeSUT(projects: projects)

        #expect(throws: CodeLaunchError.missingProject) {
            try sut.openProject(name: nil)
        }
        #expect(picker.capturedSingleSelectionPrompts == ["Select a Project"])
        #expect(console.lines.contains(where: { $0.contains("Could not resolve local path for Broken") }))
        #expect(shell.executedCommands.isEmpty)
    }
}


// MARK: - SUT
private extension FinderHandlerTests {
    func makeSUT(
        categories: [LaunchCategory] = [],
        groups: [LaunchGroup] = [],
        projects: [LaunchProject] = [],
        selectionIndex: Int = 0,
        treeNavigationOutcome: MockTreeSelectionOutcome = .none
    ) -> (sut: FinderHandler, picker: MockSwiftPicker, shell: MockLaunchShell, console: MockConsoleOutput) {
        let picker = MockSwiftPicker(
            permissionResult: .init(defaultValue: true, type: .ordered([true])),
            selectionResult: .init(defaultSingle: .index(selectionIndex)),
            treeNavigationResult: .init(defaultOutcome: treeNavigationOutcome)
        )
        let shell = MockLaunchShell()
        let console = MockConsoleOutput()
        let loader = StubFinderLoader(categories: categories, groups: groups, projects: projects)
        let sut = FinderHandler(shell: shell, picker: picker, loader: loader, console: console)

        return (sut, picker, shell, console)
    }
}


// MARK: - Mocks
private final class StubFinderLoader: FinderInfoLoader {
    private let categories: [LaunchCategory]
    private let groups: [LaunchGroup]
    private let projects: [LaunchProject]

    init(categories: [LaunchCategory], groups: [LaunchGroup], projects: [LaunchProject]) {
        self.categories = categories
        self.groups = groups
        self.projects = projects
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
}
