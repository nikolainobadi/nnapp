//
//  TerminalManagerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import Foundation
import NnShellTesting
@testable import nnapp

struct TerminalManagerTests {
    
}


// MARK: - SUT
private extension TerminalManagerTests {
    func makeSUT(scriptToLoad: String? = nil) -> (sut: TerminalManager, shell: MockShell) {
        let shell = MockShell()
        let loader = StubLoader(scriptToLoad: scriptToLoad)
        let sut = TerminalManager(shell: shell, loader: loader)
        
        
        return (sut, shell)
    }
}


// MARK: - Mocks
private extension TerminalManagerTests {
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
