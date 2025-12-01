////
////  MockShell.swift
////  nnapp
////
////  Created by Nikolai Nobadi on 3/28/25.
////
//
//import Foundation
//@testable import nnapp
//
//final class MockShell {
//    private let shouldThrowError: Bool
//    private let errorMessage = "MockShell error"
//    private var runResults: [String]
//    private var scriptResults: [String]
//    private(set) var scripts: [String] = []
//    private(set) var printedCommands: [String] = []
//    
//    init(runResults: [String] = [], scriptResults: [String] = [], shouldThrowError: Bool = false) {
//        self.runResults = runResults
//        self.scriptResults = scriptResults
//        self.shouldThrowError = shouldThrowError
//    }
//}
//
//
//// MARK: - Shell
//extension MockShell: Shell {
//    func run(_ command: String) throws -> String {
//        printedCommands.append(command)
//        if shouldThrowError {
//            throw NSError(domain: "MockShell", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
//        }
//        
//        return runResults.isEmpty ? "" : runResults.removeFirst()
//    }
//
//    func runAndPrint(_ command: String) throws {
//        printedCommands.append(command)
//        if shouldThrowError {
//            throw NSError(domain: "MockShell", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
//        }
//    }
//    
//    func runAppleScript(script: String) throws -> String {
//        scripts.append(script)
//        if shouldThrowError {
//            throw NSError(domain: "MockShell", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
//        }
//        
//        return scriptResults.isEmpty ? "" : scriptResults.removeFirst()
//    }
//}
//
