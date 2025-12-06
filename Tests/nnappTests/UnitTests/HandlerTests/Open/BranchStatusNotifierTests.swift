//
//  BranchStatusNotifierTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/11/25.
//

import Testing
import CodeLaunchKit
import NnShellTesting
@testable import nnapp

struct BranchStatusNotifierTests {
    @Test("Notifies when branch is behind")
    func notifiesWhenBranchIsBehind() throws {
        let (sut, shell) = makeSUT()
        let project = makeProject(name: "BehindProject")

        sut.notify(status: .behind, for: project)

        #expect(shell.executedCommands.count == 1)
        #expect(shell.executedCommand(containing: "BEHIND"))
        #expect(shell.executedCommand(containing: project.name))
        #expect(shell.executedCommand(containing: "display notification"))
    }

    @Test("Notifies when branch has diverged")
    func notifiesWhenBranchHasDiverged() throws {
        let (sut, shell) = makeSUT()
        let project = makeProject(name: "DivergedProject")

        sut.notify(status: .diverged, for: project)

        #expect(shell.executedCommands.count == 1)
        #expect(shell.executedCommand(containing: "DIVERGED"))
        #expect(shell.executedCommand(containing: project.name))
        #expect(shell.executedCommand(containing: "display notification"))
    }
}


// MARK: - SUT
private extension BranchStatusNotifierTests {
    func makeSUT() -> (sut: BranchStatusNotifier, shell: MockLaunchShell) {
        let shell = MockLaunchShell()
        let sut = BranchStatusNotifier(shell: shell)
        
        return (sut, shell)
    }
}
