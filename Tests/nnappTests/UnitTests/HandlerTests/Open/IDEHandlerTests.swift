//
//  IDEHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import Foundation
import CodeLaunchKit
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

struct IDEHandlerTests {
    @Test("Throws when project is missing required paths")
    func throwsWhenProjectIsMissingPaths() {
        let sut = makeSUT().sut
        let project = makeProject(group: nil)

        #expect(throws: CodeLaunchError.missingProject) {
            try sut.openInIDE(project, launchType: .xcode)
        }
    }

    @Test("Opens existing project in xcode without cloning")
    func opensExistingProjectInXcodeWithoutCloning() throws {
        let projectGroup = makeProjectGroup()
        let project = makeProject(name: "Existing", group: projectGroup)
        let (sut, shell, fileSystem) = makeSUT(directoryToLoad: .init(path: try #require(project.folderPath)))
        let filePath = try #require(project.filePath)
        let folderPath = try #require(project.folderPath)

        try sut.openInIDE(project, launchType: .xcode)

        #expect(fileSystem.capturedPaths.contains(folderPath))
        #expect(shell.executedCommand(containing: "open"))
        #expect(shell.executedCommand(containing: filePath))
        #expect(!shell.executedCommand(containing: "git"))
        #expect(!shell.executedCommand(containing: "clone"))
    }

    @Test("Clones project when missing locally and remote exists", arguments: [LaunchType.xcode, LaunchType.vscode])
    func clonesProjectWhenMissingLocallyAndRemoteExists(launchType: LaunchType) throws {
        let projectGroup = makeProjectGroup(path: "/tmp/remoteGroup")
        let projectLink = makeProjectLink(urlString: "https://github.com/example/repo")
        let project = makeProject(name: "Clonable", remote: projectLink, group: projectGroup)
        let (sut, shell, fileSystem) = makeSUT(directoryToLoad: nil)
        let folderPath = try #require(project.folderPath)

        try sut.openInIDE(project, launchType: launchType)

        #expect(fileSystem.capturedPaths.contains(folderPath))
        #expect(shell.executedCommand(containing: "git"))
        #expect(shell.executedCommand(containing: "clone"))
    }

    @Test("Opens existing project in VSCode without cloning")
    func opensExistingProjectInVSCodeWithoutCloning() throws {
        let projectGroup = makeProjectGroup()
        let project = makeProject(name: "ExistingVSCode", type: .package, group: projectGroup)
        let folderPath = try #require(project.folderPath)
        let (sut, shell, fileSystem) = makeSUT(directoryToLoad: .init(path: folderPath))

        try sut.openInIDE(project, launchType: .vscode)

        #expect(fileSystem.capturedPaths.contains(folderPath))
        #expect(shell.executedCommand(containing: "code"))
        #expect(shell.executedCommand(containing: folderPath))
        #expect(!shell.executedCommand(containing: "git"))
        #expect(!shell.executedCommand(containing: "clone"))
    }

    @Test("Throws when missing locally and no remote exists")
    func throwsWhenMissingLocallyAndNoRemoteExists() {
        let projectGroup = makeProjectGroup()
        let project = makeProject(name: "NoRemote", remote: nil, group: projectGroup)
        let (sut, shell, _) = makeSUT(directoryToLoad: nil)
        
        #expect(throws: CodeLaunchError.noRemoteRepository) {
            try sut.openInIDE(project, launchType: .xcode)
        }
        #expect(shell.executedCommands.isEmpty)
    }
}


// MARK: - SUT
private extension IDEHandlerTests {
    func makeSUT(homeDirectoryPath: String = "/Users/test", directoryToLoad: MockDirectory? = nil) -> (sut: IDEHandler, shell: MockLaunchShell, fileSystem: MockFileSystem) {
        let shell = MockLaunchShell()
        let picker = MockSwiftPicker(permissionResult: .init(defaultValue: true, type: .ordered([true])))
        let fileSystem = MockFileSystem(homeDirectory: .init(path: homeDirectoryPath), directoryToLoad: directoryToLoad)
        let sut = IDEHandler(shell: shell, picker: picker, fileSystem: fileSystem)
        
        return (sut, shell, fileSystem)
    }
}
