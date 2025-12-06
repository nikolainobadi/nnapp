//
//  MockConsoleOutput.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

@testable import nnapp

final class MockConsoleOutput: ConsoleOutput {
    private(set) var lines: [String] = []
    private(set) var headers: [String] = []
    private(set) var messages: [String] = []

    func print(_ message: String) {
        messages.append(message)
    }

    func printLine(_ message: String) {
        lines.append(message)
    }

    func printHeader(_ title: String) {
        headers.append(title)
    }

    func reset() {
        messages.removeAll()
        lines.removeAll()
        headers.removeAll()
    }
}
