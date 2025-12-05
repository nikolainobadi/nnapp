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
    func opensExistingProjectWithoutCloning() throws {
        let projectGroup = makeProjectGroup()
        let directoryPath = "existing/project"
        let project = makeProject(name: "Existing", group: projectGroup)
        let (sut, shell, fileSystem) = makeSUT(directoryToLoad: .init(path: directoryPath))
        let filePath = try #require(project.filePath)

        try sut.openInIDE(project, launchType: .xcode)

        #expect(fileSystem.capturedPaths.count == 1)
        #expect(shell.executedCommands.count == 1)
        #expect(shell.executedCommand(containing: "open"))
        #expect(shell.executedCommand(containing: filePath))
        #expect(!shell.executedCommands.contains(where: { $0.contains("git clone") }))
    }
}


// MARK: - SUT
private extension IDEHandlerTests {
    func makeSUT(homeDirectoryPath: String = "/Users/test", directoryToLoad: MockDirectory? = nil) -> (sut: IDEHandler, shell: MockShell, fileSystem: MockFileSystem) {
        let shell = MockShell()
        let picker = MockSwiftPicker(permissionResult: .init(defaultValue: true, type: .ordered([true])))
        let fileSystem = MockFileSystem(homeDirectory: .init(path: homeDirectoryPath), directoryToLoad: directoryToLoad)
        let sut = IDEHandler(shell: shell, picker: picker, fileSystem: fileSystem)
        
        return (sut, shell, fileSystem)
    }
}
