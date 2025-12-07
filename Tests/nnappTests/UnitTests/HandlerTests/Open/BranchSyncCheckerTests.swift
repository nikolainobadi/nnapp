//
//  BranchSyncCheckerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import Testing
import CodeLaunchKit
@testable import nnapp

struct BranchSyncCheckerTests {
    @Test("Returns nil when project has no remote")
    func returnsNilWhenProjectHasNoRemote() {
        let (sut, shell, _, project) = makeSUT(remoteExists: false)
        let status = sut.checkBranchSyncStatus(for: project)

        #expect(status == nil)
        #expect(shell.executedCommands.isEmpty)
    }
}


// MARK: - Skip Conditions
extension BranchSyncCheckerTests {
    @Test("Returns nil when project folder path is missing")
    func returnsNilWhenProjectFolderPathIsMissing() {
        let (sut, shell, _, project) = makeSUT(groupPath: nil)
        let status = sut.checkBranchSyncStatus(for: project)

        #expect(status == nil)
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Returns nil when folder cannot be loaded")
    func returnsNilWhenFolderCannotBeLoaded() {
        let (sut, _, fileSystem, project) = makeSUT(directoryToLoad: nil)
        let status = sut.checkBranchSyncStatus(for: project)

        #expect(status == nil)
        #expect(fileSystem.capturedPaths.count == 1)
    }

    @Test("Returns nil when git repository or remote is missing")
    func returnsNilWhenGitRepositoryOrRemoteIsMissing() {
        let (sut, shell, _, project) = makeSUT(localExists: false, remoteExists: false)
        let status = sut.checkBranchSyncStatus(for: project)

        #expect(status == nil)
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Returns nil when fetching origin fails")
    func returnsNilWhenFetchingOriginFails() {
        let (sut, shell, _, project) = makeSUT(
            gitResults: [],
            shouldThrowOnGitResultExhaustion: true
        )

        let status = sut.checkBranchSyncStatus(for: project)

        #expect(status == nil)
        #expect(shell.executedCommands.count == 1)
    }
}


// MARK: - Sync Status
extension BranchSyncCheckerTests {
    @Test("Returns behind when current branch is behind")
    func returnsBehindWhenCurrentBranchIsBehind() throws {
        let (sut, shell, _, project) = makeSUT(
            gitResults: ["ok", "feature", "0\t1"]
        )

        let status = sut.checkBranchSyncStatus(for: project)

        #expect(status == .behind)
        #expect(shell.executedCommands.count == 3)
    }

    @Test("Returns diverged when current branch has diverged")
    func returnsDivergedWhenCurrentBranchHasDiverged() {
        let (sut, shell, _, project) = makeSUT(
            gitResults: ["ok", "feature", "1\t1"]
        )

        let status = sut.checkBranchSyncStatus(for: project)

        #expect(status == .diverged)
        #expect(shell.executedCommands.count == 3)
    }

    @Test("Checks main branch when current branch is in sync")
    func checksMainBranchWhenCurrentBranchIsInSync() {
        let (sut, shell, _, project) = makeSUT(
            gitResults: ["ok", "feature", "0\t0", "0\t2"]
        )

        let status = sut.checkBranchSyncStatus(for: project)

        #expect(status == .behind)
        #expect(shell.executedCommands.count == 4)
    }
}


// MARK: - SUT
private extension BranchSyncCheckerTests {
    func makeSUT(
        groupPath: String? = "/tmp/group",
        directoryToLoad: MockDirectory? = nil,
        localExists: Bool = true,
        remoteExists: Bool = true,
        gitResults: [String] = [],
        shouldThrowOnGitResultExhaustion: Bool = false
    ) -> (sut: BranchSyncChecker, shell: MockLaunchShell, fileSystem: MockFileSystem, project: LaunchProject) {
        let folderPath = groupPath?.appendingPathComponent("Project")
        let folder = directoryToLoad ?? folderPath.map { MockDirectory(path: $0) }
        let shell = MockLaunchShell(
            localExists: localExists,
            remoteExists: remoteExists,
            results: gitResults,
            shouldThrowErrorOnFinal: shouldThrowOnGitResultExhaustion
        )
        let fileSystem = MockFileSystem(homeDirectory: MockDirectory(path: "/Users/test"), directoryToLoad: folder)
        let group = makeProjectGroup(name: "Group", path: groupPath)
        let remote = remoteExists ? makeProjectLink() : nil
        let project = makeProject(name: "Project", remote: remote, group: group)
        let sut = BranchSyncChecker(shell: shell, fileSystem: fileSystem)

        return (sut, shell, fileSystem, project)
    }
}
