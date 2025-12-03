//
//  OpenProjectHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Testing
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp
@preconcurrency import Files

@MainActor
final class OpenProjectHandlerTests: MainActorTempFolderDatasource {
    private let projectName = "TestProject"
    private let projectShortcut = "tp"
    private let groupName = "TestGroup"
    private let categoryName = "TestCategory"

    init() throws {
        let testGroupFolder = TestFolder(name: groupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: categoryName, subFolders: [testGroupFolder])

        try super.init(testFolder: .init(name: "openProjectHandlerTests", subFolders: [testCategoryFolder]))
    }
}


// MARK: - Branch Status Notifications
extension OpenProjectHandlerTests {
    @Test("Does not notify when branch status is in sync")
    func doesNotNotifyWhenBranchInSync() throws {
        let (sut, syncChecker, notifier) = try makeSUT(branchStatus: nil)
        let project = try makeTestProject()

        try makeProjectFolder()
        try sut.openInIDE(project, launchType: .xcode, terminalOption: nil)

        #expect(syncChecker.checkCallCount == 1)
        #expect(notifier.notifyCallCount == 0)
    }

    @Test("Notifies when branch is behind remote")
    func notifiesWhenBranchBehind() throws {
        let (sut, syncChecker, notifier) = try makeSUT(branchStatus: .behind)
        let project = try makeTestProject()

        try makeProjectFolder()
        try sut.openInIDE(project, launchType: .xcode, terminalOption: nil)

        #expect(syncChecker.checkCallCount == 1)
        #expect(notifier.notifyCallCount == 1)
        #expect(notifier.lastStatus == .behind)
    }

    @Test("Notifies when branch has diverged from remote")
    func notifiesWhenBranchDiverged() throws {
        let (sut, syncChecker, notifier) = try makeSUT(branchStatus: .diverged)
        let project = try makeTestProject()

        try makeProjectFolder()
        try sut.openInIDE(project, launchType: .xcode, terminalOption: nil)

        #expect(syncChecker.checkCallCount == 1)
        #expect(notifier.notifyCallCount == 1)
        #expect(notifier.lastStatus == .diverged)
    }

    @Test("Provides project information to notifier")
    func providesProjectToNotifier() throws {
        let (sut, _, notifier) = try makeSUT(branchStatus: .behind)
        let project = try makeTestProject()

        try makeProjectFolder()
        try sut.openInIDE(project, launchType: .xcode, terminalOption: nil)

        #expect(notifier.lastProject?.name == project.name)
        #expect(notifier.lastProject?.shortcut == project.shortcut)
    }

    @Test("Checks branch status for correct project")
    func checksBranchStatusForCorrectProject() throws {
        let (sut, syncChecker, _) = try makeSUT(branchStatus: nil)
        let project = try makeTestProject()

        try makeProjectFolder()
        try sut.openInIDE(project, launchType: .xcode, terminalOption: nil)

        #expect(syncChecker.lastProject?.name == project.name)
        #expect(syncChecker.lastProject?.shortcut == project.shortcut)
    }
}


// MARK: - SUT
private extension OpenProjectHandlerTests {
    func makeSUT(branchStatus: LaunchBranchStatus? = nil) throws -> (sut: OpenProjectHandler, syncChecker: MockBranchSyncChecker, notifier: MockBranchStatusNotifier) {
        let syncChecker = MockBranchSyncChecker(result: branchStatus)
        let notifier = MockBranchStatusNotifier()
        let factory = try makeContextFactory()
        let picker = factory.makePicker()
        let context = try factory.makeContext()
        let shell = factory.makeShell()
        let ideLauncher = IDELauncher(shell: shell, picker: picker)
        let terminalManager = TerminalManager(shell: shell, context: context)
        let urlLauncher = URLLauncher(shell: shell, picker: picker)

        let sut = OpenProjectHandler(
            picker: picker,
            context: context,
            ideLauncher: ideLauncher,
            terminalManager: terminalManager,
            urlLauncher: urlLauncher,
            branchSyncChecker: syncChecker,
            branchStatusNotifier: notifier
        )

        return (sut, syncChecker, notifier)
    }

    @discardableResult
    func makeProjectFolder() throws -> Folder {
        let categoryFolder = try tempFolder.subfolder(named: categoryName)
        let groupFolder = try categoryFolder.subfolder(named: groupName)

        return try groupFolder.createSubfolder(named: projectName)
    }

    func makeTestProject() throws -> LaunchProject {
        let factory = try makeContextFactory()
        let context = try factory.makeContext()
        let categoryFolder = try tempFolder.subfolder(named: categoryName)
        let category = makeCategory(name: categoryName, path: categoryFolder.path)
        let group = makeGroup(name: groupName)
        let project = makeProject(name: projectName, shortcut: projectShortcut)

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        return project
    }

    func makeContextFactory() throws -> MockContextFactory {
        let picker = MockSwiftPicker(
            permissionResult: .init(defaultValue: true),
            selectionResult: .init(defaultSingle: .index(0))
        )

        return MockContextFactory(shell: MockShell(), picker: picker)
    }
}


// MARK: - Mocks
private extension OpenProjectHandlerTests {
    final class MockBranchSyncChecker: BranchSyncChecker {
        private let result: LaunchBranchStatus?
        private(set) var checkCallCount = 0
        private(set) var lastProject: LaunchProject?

        init(result: LaunchBranchStatus?) {
            self.result = result
        }

        func checkBranchSyncStatus(for project: LaunchProject) -> LaunchBranchStatus? {
            checkCallCount += 1
            lastProject = project
            return result
        }
    }

    final class MockBranchStatusNotifier: BranchStatusNotifier {
        private(set) var notifyCallCount = 0
        private(set) var lastStatus: LaunchBranchStatus?
        private(set) var lastProject: LaunchProject?

        func notify(status: LaunchBranchStatus, for project: LaunchProject) {
            notifyCallCount += 1
            lastStatus = status
            lastProject = project
        }
    }
}
