//
//  FinderControllerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

struct FinderControllerTests {
    @Test("Browse all prints placeholder when no categories exist")
    func browseAllPrintsPlaceholderWhenNoCategoriesExist() throws {
        let (sut, shell, console) = makeSUT(categories: [])

        try sut.browseAll()

        #expect(console.lines.contains("No categories found. Create a category first."))
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Browse all prints message when selection is nil")
    func browseAllPrintsMessageWhenSelectionIsNil() throws {
        let category = LaunchCategory.new(name: "Cat", path: "/tmp/cat", groups: [])
        let (sut, shell, console) = makeSUT(
            categories: [category],
            treeNavigationOutcome: .none
        )

        try sut.browseAll()

        #expect(console.lines.contains("No selection made."))
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Browse all opens selected path")
    func browseAllOpensSelectedPath() throws {
        let category = LaunchCategory.new(name: "Cat", path: "/tmp/cat", groups: [])
        let (sut, shell, _) = makeSUT(
            categories: [category],
            treeNavigationOutcome: .index(0)
        )

        try sut.browseAll()

        #expect(shell.executedCommand(containing: "open -a Finder /tmp/cat"))
    }
}


// MARK: - Category
extension FinderControllerTests {
    @Test("Open category uses direct match without prompts")
    func openCategoryUsesDirectMatchWithoutPrompts() throws {
        let category = LaunchCategory.new(name: "iOS", path: "/tmp/ios", groups: [])
        let (sut, shell, _) = makeSUT(categories: [category])

        try sut.openCategory(name: "ios")

        #expect(shell.executedCommand(containing: "/tmp/ios"))
    }

    @Test("Uses case-insensitive matching for category name")
    func usesCaseInsensitiveMatchingForCategoryName() throws {
        let category = LaunchCategory.new(name: "MixedCase", path: "/tmp/mixed", groups: [])
        let (sut, shell, _) = makeSUT(categories: [category])

        try sut.openCategory(name: "MIXEDCASE")

        #expect(shell.executedCommand(containing: "/tmp/mixed"))
    }

    @Test("Open category prompts when name missing")
    func openCategoryPromptsWhenNameMissing() throws {
        let categories = [
            LaunchCategory.new(name: "iOS", path: "/tmp/ios", groups: []),
            LaunchCategory.new(name: "Server", path: "/tmp/server", groups: [])
        ]
        let (sut, shell, _) = makeSUT(categories: categories, selectionIndex: 1)

        try sut.openCategory(name: nil)

        #expect(shell.executedCommand(containing: "/tmp/server"))
    }

    @Test("Prompts to select when category name not found")
    func promptsToSelectWhenCategoryNameNotFound() throws {
        let categories = [
            LaunchCategory.new(name: "iOS", path: "/tmp/ios", groups: []),
            LaunchCategory.new(name: "Server", path: "/tmp/server", groups: [])
        ]
        let (sut, shell, _) = makeSUT(categories: categories, selectionIndex: 0)

        try sut.openCategory(name: "NonExistent")

        #expect(shell.executedCommand(containing: "/tmp/ios"))
    }
}


// MARK: - Group
extension FinderControllerTests {
    @Test("Open group uses direct match without prompts")
    func openGroupUsesDirectMatchWithoutPrompts() throws {
        let category = LaunchCategory.new(name: "Cat", path: "/tmp/cat", groups: [])
        let groupCategory = makeGroupCategory(name: category.name, path: category.path)
        let group = makeGroup(name: "Backend", shortcut: "be", projects: [], category: groupCategory)
        let (sut, shell, _) = makeSUT(categories: [category], groups: [group])

        try sut.openGroup(name: "BE")

        #expect(shell.executedCommand(containing: try #require(group.path)))
    }

    @Test("Matches group by name using case-insensitive comparison")
    func matchesGroupByNameUsingCaseInsensitiveComparison() throws {
        let group = makeGroup(name: "MixedCase", category: makeGroupCategory(path: "/tmp/cat"))
        let (sut, shell, _) = makeSUT(groups: [group])

        try sut.openGroup(name: "MIXEDCASE")

        #expect(shell.executedCommand(containing: try #require(group.path)))
    }

    @Test("Matches group by shortcut using case-insensitive comparison")
    func matchesGroupByShortcutUsingCaseInsensitiveComparison() throws {
        let group = makeGroup(name: "Backend", shortcut: "be", category: makeGroupCategory(path: "/tmp/cat"))
        let (sut, shell, _) = makeSUT(groups: [group])

        try sut.openGroup(name: "BE")

        #expect(shell.executedCommand(containing: try #require(group.path)))
    }

    @Test("Open group prompts then selects when name missing")
    func openGroupPromptsThenSelectsWhenNameMissing() throws {
        let groups = [
            makeGroup(name: "Backend", shortcut: "be", projects: [], category: makeGroupCategory(path: "/tmp/backend")),
            makeGroup(name: "Frontend", shortcut: "fe", projects: [], category: makeGroupCategory(path: "/tmp/frontend"))
        ]
        let (sut, shell, _) = makeSUT(groups: groups, selectionIndex: 1)

        try sut.openGroup(name: nil)

        #expect(shell.executedCommand(containing: try #require(groups[1].path)))
    }

    @Test("Prompts to select when group name not found")
    func promptsToSelectWhenGroupNameNotFound() throws {
        let groups = [
            makeGroup(name: "Backend", category: makeGroupCategory(path: "/tmp/backend")),
            makeGroup(name: "Frontend", category: makeGroupCategory(path: "/tmp/frontend"))
        ]
        let (sut, shell, _) = makeSUT(groups: groups, selectionIndex: 0)

        try sut.openGroup(name: "NonExistent")

        #expect(shell.executedCommand(containing: try #require(groups[0].path)))
    }

    @Test("Open group throws when selected group has no path")
    func openGroupThrowsWhenSelectedGroupHasNoPath() {
        let groups = [
            LaunchGroup.new(name: "Backend", shortcut: "be", projects: []),
            LaunchGroup.new(name: "Frontend", shortcut: "fe", projects: [])
        ]
        let (sut, shell, console) = makeSUT(groups: groups, selectionIndex: 0)

        #expect(throws: CodeLaunchError.missingGroup) {
            try sut.openGroup(name: nil)
        }
        #expect(console.lines.contains(where: { $0.contains("Could not resolve local path for Backend") }))
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Throws when group found by name but has no path")
    func throwsWhenGroupFoundByNameButHasNoPath() {
        let group = LaunchGroup.new(name: "Backend", shortcut: "be", projects: [])
        let (sut, shell, console) = makeSUT(groups: [group])

        #expect(throws: CodeLaunchError.missingGroup) {
            try sut.openGroup(name: "Backend")
        }
        #expect(console.lines.contains(where: { $0.contains("Could not resolve local path for Backend") }))
        #expect(shell.executedCommands.isEmpty)
    }
}


// MARK: - Project
extension FinderControllerTests {
    @Test("Open project uses direct match without prompts")
    func openProjectUsesDirectMatchWithoutPrompts() throws {
        let group = makeProjectGroup(path: "/tmp/group")
        let project = makeProject(name: "API", shortcut: "api", group: group)
        let (sut, shell, _) = makeSUT(projects: [project])

        try sut.openProject(name: "API")

        let path = try #require(project.folderPath)
        #expect(shell.executedCommand(containing: path))
    }

    @Test("Matches project by name using case-insensitive comparison")
    func matchesProjectByNameUsingCaseInsensitiveComparison() throws {
        let group = makeProjectGroup(path: "/tmp/group")
        let project = makeProject(name: "MixedCase", group: group)
        let (sut, shell, _) = makeSUT(projects: [project])

        try sut.openProject(name: "MIXEDCASE")

        let path = try #require(project.folderPath)
        #expect(shell.executedCommand(containing: path))
    }

    @Test("Matches project by shortcut using case-insensitive comparison")
    func matchesProjectByShortcutUsingCaseInsensitiveComparison() throws {
        let group = makeProjectGroup(path: "/tmp/group")
        let project = makeProject(name: "API", shortcut: "api", group: group)
        let (sut, shell, _) = makeSUT(projects: [project])

        try sut.openProject(name: "API")

        let path = try #require(project.folderPath)
        #expect(shell.executedCommand(containing: path))
    }

    @Test("Open project prompts then selects when name missing")
    func openProjectPromptsThenSelectsWhenNameMissing() throws {
        let group = makeProjectGroup(path: "/tmp/group")
        let projects = [
            makeProject(name: "API", shortcut: "api", group: group),
            makeProject(name: "Web", shortcut: "web", group: group)
        ]
        let (sut, shell, _) = makeSUT(projects: projects, selectionIndex: 1)

        try sut.openProject(name: nil)

        let selectedPath = try #require(projects[1].folderPath)
        #expect(shell.executedCommand(containing: selectedPath))
    }

    @Test("Prompts to select when project name not found")
    func promptsToSelectWhenProjectNameNotFound() throws {
        let group = makeProjectGroup(path: "/tmp/group")
        let projects = [
            makeProject(name: "API", group: group),
            makeProject(name: "Web", group: group)
        ]
        let (sut, shell, _) = makeSUT(projects: projects, selectionIndex: 0)

        try sut.openProject(name: "NonExistent")

        let path = try #require(projects[0].folderPath)
        #expect(shell.executedCommand(containing: path))
    }

    @Test("Open project throws when selected project has no path")
    func openProjectThrowsWhenSelectedProjectHasNoPath() {
        let projects = [makeProject(name: "Broken", shortcut: "brk", group: nil)]
        let (sut, shell, console) = makeSUT(projects: projects)

        #expect(throws: CodeLaunchError.missingProject) {
            try sut.openProject(name: nil)
        }
        #expect(console.lines.contains(where: { $0.contains("Could not resolve local path for Broken") }))
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Throws when project found by name but has no path")
    func throwsWhenProjectFoundByNameButHasNoPath() {
        let project = makeProject(name: "Broken", shortcut: "brk", group: nil)
        let (sut, shell, console) = makeSUT(projects: [project])

        #expect(throws: CodeLaunchError.missingProject) {
            try sut.openProject(name: "Broken")
        }
        #expect(console.lines.contains(where: { $0.contains("Could not resolve local path for Broken") }))
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Throws when project found by shortcut but has no path")
    func throwsWhenProjectFoundByShortcutButHasNoPath() {
        let project = makeProject(name: "Broken", shortcut: "brk", group: nil)
        let (sut, shell, console) = makeSUT(projects: [project])

        #expect(throws: CodeLaunchError.missingProject) {
            try sut.openProject(name: "brk")
        }
        #expect(console.lines.contains(where: { $0.contains("Could not resolve local path for Broken") }))
        #expect(shell.executedCommands.isEmpty)
    }
}


// MARK: - SUT
private extension FinderControllerTests {
    func makeSUT(
        categories: [LaunchCategory] = [],
        groups: [LaunchGroup] = [],
        projects: [LaunchProject] = [],
        selectionIndex: Int = 0,
        treeNavigationOutcome: MockTreeSelectionOutcome = .none
    ) -> (sut: FinderController, shell: MockLaunchShell, console: MockConsoleOutput) {
        let picker = MockSwiftPicker(
            permissionResult: .init(defaultValue: true, type: .ordered([true])),
            selectionResult: .init(defaultSingle: .index(selectionIndex)),
            treeNavigationResult: .init(defaultOutcome: treeNavigationOutcome)
        )
        let shell = MockLaunchShell()
        let console = MockConsoleOutput()
        let loader = StubFinderLoader(categories: categories, groups: groups, projects: projects)
        let sut = FinderController(shell: shell, picker: picker, loader: loader, console: console)

        return (sut, shell, console)
    }
}


// MARK: - Mocks
private extension FinderControllerTests {
    final class StubFinderLoader: FinderInfoLoader {
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
}
