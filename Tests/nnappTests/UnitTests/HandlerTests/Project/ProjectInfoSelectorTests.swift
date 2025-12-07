//
//  ProjectInfoSelectorTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import Testing
import CodeLaunchKit
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

struct ProjectInfoSelectorTests {
    @Test("Throws when project name already exists")
    func throwsWhenProjectNameAlreadyExists() {
        let folder = MockDirectory(path: "/tmp/existing")
        let project = makeProject(name: "Existing")
        let group = LaunchGroup.new(name: "Group", shortcut: nil)
        let sut = makeSUT(projects: [project]).sut

        #expect(throws: CodeLaunchError.projectNameTaken) {
            _ = try sut.selectProjectInfo(folder: folder, shortcut: nil, group: group, isMainProject: true)
        }
    }

    @Test("Throws when shortcut matches existing group or project")
    func throwsWhenShortcutMatchesExistingGroupOrProject() {
        let folder = MockDirectory(path: "/tmp/new-project")
        let group = LaunchGroup.new(name: "Group", shortcut: nil)
        let existingProject = makeProject(name: "Other", shortcut: "abc")
        let existingGroup = LaunchGroup.new(name: "ExistingGroup", shortcut: "abc", projects: [existingProject])
        let sut = makeSUT(projects: [existingProject], groups: [existingGroup]).sut

        #expect(throws: CodeLaunchError.shortcutTaken) {
            _ = try sut.selectProjectInfo(folder: folder, shortcut: "ABC", group: group, isMainProject: true)
        }
    }

    @Test("Returns nil shortcut when secondary project declines quick launch")
    func returnsNilShortcutWhenSecondaryProjectDeclinesQuickLaunch() throws {
        let folder = MockDirectory(path: "/tmp/feature")
        let group = LaunchGroup.new(name: "Group", shortcut: "grp")
        let sut = makeSUT(permissionResults: [false, false], permissionDefault: false).sut

        let info = try sut.selectProjectInfo(folder: folder, shortcut: nil, group: group, isMainProject: false)

        #expect(info.name == folder.name)
        #expect(info.shortcut == nil)
        #expect(info.remote == nil)
        #expect(info.otherLinks.isEmpty)
    }

    @Test("Returns project info with shortcut remote and custom links when confirmed")
    func returnsProjectInfoWithShortcutRemoteAndCustomLinksWhenConfirmed() throws {
        let folder = MockDirectory(path: "/tmp/NewProject")
        let group = LaunchGroup.new(name: "Group", shortcut: nil)
        let gitHubURL = "https://github.com/example/repo"
        let (sut, shell) = makeSUT(
            inputResults: ["np", "Docs", "https://docs.example"],
            permissionResults: [true, true, false],
            gitHubURLResults: [gitHubURL]
        )

        let info = try sut.selectProjectInfo(folder: folder, shortcut: nil, group: group, isMainProject: true)

        #expect(info.name == folder.name)
        #expect(info.shortcut == "np")
        #expect(info.remote == ProjectLink(name: "GitHub", urlString: gitHubURL))
        #expect(info.otherLinks == [ProjectLink(name: "Docs", urlString: "https://docs.example")])
        #expect(shell.executedCommands.contains { $0.contains(folder.path) })
    }

    @Test("Omits remote when GitHub URL is not confirmed")
    func omitsRemoteWhenGitHubURLIsNotConfirmed() throws {
        let folder = MockDirectory(path: "/tmp/newProject")
        let group = LaunchGroup.new(name: "Group", shortcut: nil)
        let gitHubURL = "https://github.com/example/repo"
        let (sut, _) = makeSUT(
            inputResults: ["sc"],
            permissionResults: [false, false],
            permissionDefault: false,
            gitHubURLResults: [gitHubURL]
        )

        let info = try sut.selectProjectInfo(folder: folder, shortcut: nil, group: group, isMainProject: true)

        #expect(info.remote == nil)
        #expect(info.shortcut == "sc")
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
    ) -> (sut: ProjectInfoSelector, shell: MockLaunchShell) {
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(defaultValue: permissionDefault, type: .ordered(permissionResults)),
            selectionResult: .init(defaultSingle: .index(selectionIndex))
        )
        let infoLoader = StubProjectInfoLoader(projects: projects, groups: groups, linkNames: linkNames)
        let shell = MockLaunchShell(results: gitHubURLResults)
        let sut = ProjectInfoSelector(shell: shell, picker: picker, infoLoader: infoLoader)

        return (sut, shell)
    }
}


// MARK: - Mocks
private extension ProjectInfoSelectorTests {
    final class StubProjectInfoLoader: ProjectInfoLoader {
        private let projects: [LaunchProject]
        private let groups: [LaunchGroup]
        private let linkNames: [String]
        
        init(projects: [LaunchProject] = [], groups: [LaunchGroup] = [], linkNames: [String] = []) {
            self.projects = projects
            self.groups = groups
            self.linkNames = linkNames
        }
        
        func loadProjects() throws -> [LaunchProject] {
            return projects
        }
        
        func loadGroups() throws -> [LaunchGroup] {
            return groups
        }
        
        func loadProjectLinkNames() -> [String] {
            return linkNames
        }
    }
}
