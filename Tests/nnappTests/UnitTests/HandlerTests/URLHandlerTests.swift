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
        let picker = MockSwiftPicker(
            selectionResult: .init(defaultSingle: .index(selectionIndex))
        )
        let sut = URLHandler(shell: shell, picker: picker)
        
        return (sut, shell)
    }
}
