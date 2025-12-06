//
//  URLHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import CodeLaunchKit
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

struct URLHandlerTests {
    @Test("Throws when remote URL is missing")
    func throwsWhenRemoteIsMissing() throws {
        let (sut, shell) = makeSUT()

        #expect(throws: CodeLaunchError.missingGitRepository) {
            try sut.openRemoteURL(remote: nil)
        }
        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Opens remote URL when present")
    func opensRemoteURLWhenPresent() throws {
        let (sut, shell) = makeSUT()
        let remote = makeProjectLink(name: "GitHub", urlString: "https://github.com/example")

        try sut.openRemoteURL(remote: remote)

        #expect(shell.executedCommands.count == 1)
        #expect(shell.executedCommand(containing: remote.urlString))
    }

    @Test("Opens single project link directly")
    func opensSingleProjectLinkDirectly() throws {
        let (sut, shell) = makeSUT()
        let links = [makeProjectLink()]

        try sut.openProjectLink(links: links)

        #expect(shell.executedCommands.count == 1)
        #expect(shell.executedCommand(containing: links[0].urlString))
    }

    @Test("Opens selected project link when multiple options exist")
    func opensSelectedProjectLinkWhenMultipleOptionsExist() throws {
        let (sut, shell) = makeSUT(selectionIndex: 1)
        let links = [makeProjectLink(), makeProjectLink(name: "Docs", urlString: "https://docs.example")]

        try sut.openProjectLink(links: links)

        #expect(shell.executedCommands.count == 1)
        #expect(shell.executedCommand(containing: links[1].urlString))
    }
}


// MARK: - SUT
private extension URLHandlerTests {
    func makeSUT(selectionIndex: Int = 0) -> (sut: URLHandler, shell: MockShell) {
        let shell = MockShell()
        let picker = MockSwiftPicker(selectionResult: .init(defaultSingle: .index(selectionIndex)))
        let sut = URLHandler(shell: shell, picker: picker)

        return (sut, shell)
    }
}
