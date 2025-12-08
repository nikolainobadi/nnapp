//
//  LaunchControllerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import Testing
import Foundation
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

struct LaunchControllerTests {
    @Test("Selects project from group shortcut with picker selection")
    func selectsProjectFromGroupShortcutWithPickerSelection() throws {
        let groupProjects = [
            makeProject(name: "One", shortcut: "one"),
            makeProject(name: "Two", shortcut: "two")
        ]
        let group = LaunchGroup.new(name: "Group", shortcut: "grp", projects: groupProjects)
        let sut = makeSUT(groups: [group], selectionIndex: 1).sut

        let project = try sut.selectProject(shortcut: "GRP", useGroupShortcut: true)

        #expect(project.name == "Two")
    }

    @Test("Throws when group shortcut is missing")
    func throwsWhenGroupShortcutIsMissing() {
        let sut = makeSUT(groups: []).sut

        #expect(throws: CodeLaunchError.missingGroup) {
            _ = try sut.selectProject(shortcut: "grp", useGroupShortcut: true)
        }
    }

    @Test("Selects project by shortcut when present")
    func selectsProjectByShortcutWhenPresent() throws {
        let project = makeProject(name: "CLI", shortcut: "cli")
        let sut = makeSUT(projects: [project]).sut

        let selected = try sut.selectProject(shortcut: "CLI", useGroupShortcut: false)

        #expect(selected.name == project.name)
    }

    @Test("Throws when project shortcut is missing")
    func throwsWhenProjectShortcutIsMissing() {
        let sut = makeSUT(projects: []).sut

        #expect(throws: CodeLaunchError.missingProject) {
            _ = try sut.selectProject(shortcut: "none", useGroupShortcut: false)
        }
    }
}


// MARK: - IDE Operations
extension LaunchControllerTests {
    @Test("Opens IDE and terminal then skips notification when branch status nil")
    func opensIDEAndTerminalThenSkipsNotificationWhenBranchStatusNil() throws {
        let project = makeProject(name: "App", shortcut: "app", remote: makeProjectLink(), group: makeProjectGroup(path: "/tmp/group"))
        let (sut, service) = makeSUT(branchStatus: nil)

        try sut.openInIDE(project, launchType: .xcode, terminalOption: .onlyTerminal)
        
        let folderPath = try #require(project.folderPath)

        #expect(service.openedProjectData?.project.name == project.name)
        #expect(service.openedProjectData?.type == .xcode)
        #expect(service.terminalData?.path == folderPath)
        #expect(service.terminalData?.option == .onlyTerminal)
        #expect(service.notifyData == nil)
    }

    @Test("Notifies when branch status is behind")
    func notifiesWhenBranchStatusIsBehind() throws {
        let project = makeProject(name: "App", shortcut: "app", remote: makeProjectLink(), group: makeProjectGroup(path: "/tmp/group"))
        let (sut, service) = makeSUT(branchStatus: .behind)

        try sut.openInIDE(project, launchType: .vscode, terminalOption: nil)

        #expect(service.openedProjectData?.type == .vscode)
        #expect(service.notifyData?.status == .behind)
        #expect(service.notifyData?.project.name == project.name)
    }

    @Test("Throws missing project when folder path is unavailable")
    func throwsMissingProjectWhenFolderPathIsUnavailable() {
        let project = makeProject(name: "Broken", shortcut: "brk", remote: makeProjectLink(), group: makeProjectGroup(path: nil))
        let (sut, service) = makeSUT()

        #expect(throws: CodeLaunchError.missingProject) {
            try sut.openInIDE(project, launchType: .xcode, terminalOption: nil)
        }
        #expect(service.openedProjectData == nil)
        #expect(service.terminalData == nil)
        #expect(service.notifyData == nil)
    }
}


// MARK: - URL Operations
extension LaunchControllerTests {
    @Test("Opens remote URL through service")
    func opensRemoteURLThroughService() throws {
        let remote = makeProjectLink()
        let project = makeProject(name: "Web", shortcut: "web", remote: remote, group: makeProjectGroup(path: "/tmp/group"))
        let (sut, service) = makeSUT()

        try sut.openRemoteURL(for: project)

        #expect(service.remoteLink?.urlString == remote.urlString)
    }

    @Test("Opens project link through service")
    func opensProjectLinkThroughService() throws {
        let links = [makeProjectLink(name: "Docs")]
        let project = makeProject(name: "Docs", shortcut: "docs", remote: makeProjectLink(), links: links, group: makeProjectGroup(path: "/tmp/group"))
        let (sut, service) = makeSUT()

        try sut.openProjectLink(for: project)

        #expect(service.projectLinks == links)
    }
}


// MARK: - SUT
private extension LaunchControllerTests {
    func makeSUT(
        projects: [LaunchProject] = [],
        groups: [LaunchGroup] = [],
        selectionIndex: Int = 0,
        branchStatus: LaunchBranchStatus? = nil,
        throwError: Bool = false
    ) -> (sut: LaunchController, delegate: MockOpenProjectDelegate) {
        let picker = MockSwiftPicker(selectionResult: .init(defaultSingle: .index(selectionIndex)))
        let loader = StubLoader(projects: projects, groups: groups)
        let delegate = MockOpenProjectDelegate(throwError: throwError, branchStatus: branchStatus)
        let launchService = LaunchManager(loader: loader, delegate: delegate)
        let sut = LaunchController(picker: picker, launchService: launchService, loader: loader, delegate: delegate)

        return (sut, delegate)
    }
}


// MARK: - Mocks
private extension LaunchControllerTests {
    final class StubLoader: LaunchController.Loader {
        private let groups: [LaunchGroup]
        private let projects: [LaunchProject]
        
        init(projects: [LaunchProject] = [], groups: [LaunchGroup] = []) {
            self.projects = projects
            self.groups = groups
        }
        
        func loadCategories() throws -> [LaunchCategory] {
            return []
        }
        
        func loadGroups() throws -> [LaunchGroup] {
            return groups
        }
        
        func loadProjects() throws -> [LaunchProject] {
            return projects
        }
        
        func loadProjectLinkNames() -> [String] {
            return []
        }
        
        func loadLaunchScript() -> String? {
            return nil
        }
    }
    
    final class MockOpenProjectDelegate: LaunchDelegate {
        private let throwError: Bool
        private let branchStatus: LaunchBranchStatus?

        private(set) var remoteLink: ProjectLink?
        private(set) var projectLinks: [ProjectLink] = []
        private(set) var terminalData: (path: String, option: TerminalOption?)?
        private(set) var openedProjectData: (project: LaunchProject, type: LaunchType)?
        private(set) var notifyData: (status: LaunchBranchStatus, project: LaunchProject)?

        init(throwError: Bool = false, branchStatus: LaunchBranchStatus? = nil) {
            self.throwError = throwError
            self.branchStatus = branchStatus
        }

        func openIDE(_ project: LaunchProject, launchType: LaunchType) throws {
            if throwError {
                throw NSError(domain: "MockProjectOpenService", code: 1)
            }

            openedProjectData = (project, launchType)
        }

        func openTerminal(folderPath: String, option: TerminalOption?) {
            terminalData = (folderPath, option)
        }

        func checkBranchStatus(for project: LaunchProject) -> LaunchBranchStatus? {
            return branchStatus
        }

        func notifyBranchStatus(_ status: LaunchBranchStatus, for project: LaunchProject) {
            notifyData = (status, project)
        }

        func openRemoteURL(for remote: ProjectLink?) throws {
            if throwError {
                throw NSError(domain: "MockProjectOpenService", code: 2)
            }

            remoteLink = remote
        }

        func openProjectLink(_ links: [ProjectLink]) throws {
            if throwError {
                throw NSError(domain: "MockProjectOpenService", code: 3)
            }

            projectLinks = links
        }
    }

}
