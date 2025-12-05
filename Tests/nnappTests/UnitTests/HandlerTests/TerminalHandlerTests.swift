//
//  TerminalHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import Foundation
import NnShellTesting
@testable import nnapp

struct TerminalHandlerTests {
    private let folderPath = "fake/path/to/folder"
}


// MARK: - Unit Tests
extension TerminalHandlerTests {
    @Test("Does not open terminal")
    func doesNotOpenTerminal() {
        let (sut, shell) = makeSUT()
        
        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: .noTerminal)
        
        #expect(shell.executedCommands.isEmpty)
    }
}


// MARK: - SUT
private extension TerminalHandlerTests {
    func makeSUT(scriptToLoad: String? = nil) -> (sut: TerminalHandler, shell: MockShell) {
        let shell = MockShell()
        let loader = StubLoader(scriptToLoad: scriptToLoad)
        let sut = TerminalHandler(shell: shell, loader: loader)
        
        
        return (sut, shell)
    }
}


// MARK: - Mocks
private extension TerminalHandlerTests {
    final class StubLoader: @unchecked Sendable, ScriptLoader {
        private let scriptToLoad: String?
        
        init(scriptToLoad: String?) {
            self.scriptToLoad = scriptToLoad
        }
        
        func loadLaunchScript() -> String? {
            return scriptToLoad
        }
    }
}
