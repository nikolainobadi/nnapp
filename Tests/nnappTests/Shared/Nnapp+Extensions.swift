//
//  Nnapp+Extensions.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Foundation
import ArgumentParser
@testable import nnapp

extension Nnapp {
    @discardableResult
    static func testRun(contextFactory: MockContextFactory? = nil, args: [String]?) throws -> String {
//        self.contextFactory = MockContextFactory()
        self.contextFactory = contextFactory ?? MockContextFactory()
        
        return try captureOutput(factory: contextFactory, args: args)
    }
}


// MARK: - Private Helpers
private extension Nnapp {
    static func captureOutput(factory: MockContextFactory? = nil, args: [String]?) throws -> String {
        let pipe = Pipe()
        let readHandle = pipe.fileHandleForReading
        let writeHandle = pipe.fileHandleForWriting

        let originalStdout = dup(STDOUT_FILENO) // Save original stdout
        dup2(writeHandle.fileDescriptor, STDOUT_FILENO) // Redirect stdout to pipe
        
        var command = try Self.parseAsRoot(args)
        try command.run()
        
        fflush(stdout) // Ensure all output is flushed
        dup2(originalStdout, STDOUT_FILENO) // Restore original stdout
        close(originalStdout) // Close saved stdout
        writeHandle.closeFile() // Close the writing end of the pipe

        let data = readHandle.readDataToEndOfFile() // Read the output
        readHandle.closeFile() // Close reading end

        return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
