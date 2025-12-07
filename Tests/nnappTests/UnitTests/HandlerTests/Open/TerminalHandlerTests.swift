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
    
    @Test("Opens terminal with launch script when available")
    func opensTerminalWithLaunchScriptWhenAvailable() {
        let launchScript = "source ~/.zshrc && echo hi"
        let envProvider = TestEnvironmentProvider(termProgram: "iTerm.app")
        let (sut, shell) = makeSUT(scriptToLoad: launchScript, results: [""], environment: envProvider)
        
        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: .onlyTerminal)
        
        #expect(shell.executedCommands.count == 2) // query sessions + open new tab
        #expect(shell.executedCommand(containing: "cd \(folderPath) && \(launchScript) && clear"))
    }

    @Test("Skips opening terminal when session already open")
    func skipsOpeningTerminalWhenSessionAlreadyOpen() {
        let (sut, shell) = makeSUT(results: [folderPath])

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: nil)

        #expect(!shell.executedCommand(containing: "cd \(folderPath)"))
    }
}


// MARK: - SUT
private extension TerminalHandlerTests {
    func makeSUT(scriptToLoad: String? = nil, results: [String] = [], environment: any TerminalEnvironmentProviding = TestEnvironmentProvider()) -> (sut: TerminalHandler, shell: MockShell) {
        let shell = MockLaunchShell(results: results)
        let loader = StubLoader(scriptToLoad: scriptToLoad)
        let sut = TerminalHandler(shell: shell, loader: loader, environment: environment)

        return (sut, shell)
    }
}


// MARK: - Mocks
private extension TerminalHandlerTests {
    final class StubLoader: ScriptLoader {
        private let scriptToLoad: String?
        
        init(scriptToLoad: String?) {
            self.scriptToLoad = scriptToLoad
        }
        
        func loadLaunchScript() -> String? {
            return scriptToLoad
        }
    }
    
    final class TestEnvironmentProvider: TerminalEnvironmentProviding {
        private let termProgramValue: String?
        
        init(termProgram: String? = "iTerm.app") {
            self.termProgramValue = termProgram
        }
        
        func termProgram() -> String? {
            return termProgramValue
        }
    }
}
