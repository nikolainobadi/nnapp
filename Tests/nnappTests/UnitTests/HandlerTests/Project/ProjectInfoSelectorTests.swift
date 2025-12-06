//
//  ProjectInfoSelectorTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import CodeLaunchKit
import NnShellTesting
import SwiftPickerTesting
import Testing
@testable import nnapp

struct ProjectInfoSelectorTests {
    @Test("Throws when project name already exists")
    func throwsWhenProjectNameAlreadyExists() {
        let folder = MockDirectory(path: "/tmp/existing")
        let project = makeProject(name: "Existing")
        let group = LaunchGroup.new(name: "Group", shortcut: nil)
        let (sut, _, infoLoader, _) = makeSUT(projects: [project])

        #expect(throws: CodeLaunchError.projectNameTaken) {
            _ = try sut.selectProjectInfo(folder: folder, shortcut: nil, group: group, isMainProject: true)
        }
        #expect(infoLoader.loadProjectsCallCount == 1)
        #expect(infoLoader.loadGroupsCallCount == 0)
        #expect(infoLoader.loadProjectLinkNamesCallCount == 0)
    }

    @Test("Throws when shortcut matches existing group or project")
    func throwsWhenShortcutMatchesExistingGroupOrProject() {
        let folder = MockDirectory(path: "/tmp/new-project")
        let group = LaunchGroup.new(name: "Group", shortcut: nil)
        let existingProject = makeProject(name: "Other", shortcut: "abc")
        let existingGroup = LaunchGroup.new(name: "ExistingGroup", shortcut: "abc", projects: [existingProject])
        let (sut, _, infoLoader, _) = makeSUT(projects: [existingProject], groups: [existingGroup])

        #expect(throws: CodeLaunchError.shortcutTaken) {
            _ = try sut.selectProjectInfo(folder: folder, shortcut: "ABC", group: group, isMainProject: true)
        }
        #expect(infoLoader.loadProjectsCallCount == 1)
        #expect(infoLoader.loadGroupsCallCount == 1)
        #expect(infoLoader.loadProjectLinkNamesCallCount == 0)
    }

    @Test("Returns nil shortcut when secondary project declines quick launch")
    func returnsNilShortcutWhenSecondaryProjectDeclinesQuickLaunch() throws {
        let folder = MockDirectory(path: "/tmp/feature")
        let group = LaunchGroup.new(name: "Group", shortcut: "grp")
        let (sut, _, infoLoader, _) = makeSUT(permissionResults: [false, false], permissionDefault: false)

        let info = try sut.selectProjectInfo(folder: folder, shortcut: nil, group: group, isMainProject: false)

        #expect(info.name == folder.name)
        #expect(info.shortcut == nil)
        #expect(info.remote == nil)
        #expect(info.otherLinks.isEmpty)
        #expect(infoLoader.loadProjectsCallCount == 1)
        #expect(infoLoader.loadGroupsCallCount == 0)
        #expect(infoLoader.loadProjectLinkNamesCallCount == 1)
    }

    @Test("Returns project info with shortcut remote and custom links when confirmed")
    func returnsProjectInfoWithShortcutRemoteAndCustomLinksWhenConfirmed() throws {
        let folder = MockDirectory(path: "/tmp/NewProject")
        let group = LaunchGroup.new(name: "Group", shortcut: nil)
        let gitHubURL = "https://github.com/example/repo"
        let (sut, _, infoLoader, shell) = makeSUT(
            inputResults: ["np", "Docs", "https://docs.example"],
            permissionResults: [true, true, false],
            gitHubURLResults: [gitHubURL]
        )

        let info = try sut.selectProjectInfo(folder: folder, shortcut: nil, group: group, isMainProject: true)

        #expect(info.name == folder.name)
        #expect(info.shortcut == "np")
        #expect(info.remote == ProjectLink(name: "GitHub", urlString: gitHubURL))
        #expect(info.otherLinks == [ProjectLink(name: "Docs", urlString: "https://docs.example")])
        #expect(shell.commandCount(containing: "getGitHubURL") == 1)
        #expect(shell.executedCommands.contains { $0.contains(folder.path) })
        #expect(infoLoader.loadProjectsCallCount == 1)
        #expect(infoLoader.loadGroupsCallCount == 1)
        #expect(infoLoader.loadProjectLinkNamesCallCount == 1)
    }

    @Test("Omits remote when GitHub URL is not confirmed")
    func omitsRemoteWhenGitHubURLIsNotConfirmed() throws {
        let folder = MockDirectory(path: "/tmp/newProject")
        let group = LaunchGroup.new(name: "Group", shortcut: nil)
        let gitHubURL = "https://github.com/example/repo"
        let (sut, _, infoLoader, shell) = makeSUT(
            inputResults: ["sc"],
            permissionResults: [false, false],
            permissionDefault: false,
            gitHubURLResults: [gitHubURL]
        )

        let info = try sut.selectProjectInfo(folder: folder, shortcut: nil, group: group, isMainProject: true)

        #expect(info.shortcut == "sc")
        #expect(info.remote == nil)
        #expect(shell.commandCount(containing: "getGitHubURL") == 1)
        #expect(infoLoader.loadProjectsCallCount == 1)
        #expect(infoLoader.loadGroupsCallCount == 1)
        #expect(infoLoader.loadProjectLinkNamesCallCount == 1)
    }
}


// MARK: - SUT
private extension ProjectInfoSelectorTests {
    func makeSUT(
        projects: [LaunchProject] = [],
        groups: [LaunchGroup] = [],
        linkNames: [String] = [],
        inputResults: [String] = [],
        permissionResults: [Bool] = [],
        permissionDefault: Bool = true,
        selectionIndex: Int = 0,
        gitHubURLResults: [String] = []
    ) -> (sut: ProjectInfoSelector, picker: MockSwiftPicker, infoLoader: MockProjectInfoLoader, shell: MockShell) {
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(defaultValue: permissionDefault, type: .ordered(permissionResults)),
            selectionResult: .init(defaultSingle: .index(selectionIndex))
        )
        let infoLoader = MockProjectInfoLoader(projects: projects, groups: groups, linkNames: linkNames)
        let shell = MockShell(results: gitHubURLResults)
        let sut = ProjectInfoSelector(shell: shell, picker: picker, infoLoader: infoLoader)

        return (sut, picker, infoLoader, shell)
    }
}


// MARK: - Mocks
private final class MockProjectInfoLoader: LaunchProjectInfoLoader {
    private let projects: [LaunchProject]
    private let groups: [LaunchGroup]
    private let linkNames: [String]
    private(set) var loadProjectsCallCount = 0
    private(set) var loadGroupsCallCount = 0
    private(set) var loadProjectLinkNamesCallCount = 0

    init(projects: [LaunchProject] = [], groups: [LaunchGroup] = [], linkNames: [String] = []) {
        self.projects = projects
        self.groups = groups
        self.linkNames = linkNames
    }

    func loadProjects() throws -> [LaunchProject] {
        loadProjectsCallCount += 1
        return projects
    }

    func loadGroups() throws -> [LaunchGroup] {
        loadGroupsCallCount += 1
        return groups
    }

    func loadProjectLinkNames() -> [String] {
        loadProjectLinkNamesCallCount += 1
        return linkNames
    }
}
