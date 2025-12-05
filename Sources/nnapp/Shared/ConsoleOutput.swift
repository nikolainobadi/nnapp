//
//  ConsoleOutput.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

/// Abstracts console output operations for testability.
protocol ConsoleOutput {
    /// Prints a message without a newline.
    /// - Parameter message: The message to print.
    func print(_ message: String)

    /// Prints a message with a newline.
    /// - Parameter message: The message to print.
    func printLine(_ message: String)

    /// Prints a formatted header.
    /// - Parameter title: The header title to display.
    func printHeader(_ title: String)
}


// MARK: - Default Implementation
/// Default console output implementation that writes to stdout.
struct DefaultConsoleOutput: ConsoleOutput {
    func print(_ message: String) {
        Swift.print(message, terminator: "")
    }

    func printLine(_ message: String) {
        Swift.print(message)
    }

    func printHeader(_ title: String) {
        Swift.print("\n---------- \(title.bold.underline) ----------", terminator: "\n\n")
    }
}
