//
//  MockContextFactory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import SwiftData
import Foundation
import CodeLaunchKit
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

final class MockContextFactory {
    private let shell: MockLaunchShell
    private let picker: MockSwiftPicker
    private let throwCategorySelectorError: Bool
    private var context: CodeLaunchContext?
    private let uniqueId: String
    private let folderBrowser: any DirectoryBrowser

    init(shell: MockLaunchShell = .init(), picker: MockSwiftPicker = .init(), throwCategorySelectorError: Bool = false, folderBrowser: (any DirectoryBrowser)? = nil) {
        self.shell = shell
        self.picker = picker
        self.uniqueId = UUID().uuidString
        self.throwCategorySelectorError = throwCategorySelectorError
        self.folderBrowser = folderBrowser ?? MockFolderBrowser(selectedDirectory: nil)
    }
}


// MARK: - ContextFactory
extension MockContextFactory: ContextFactory {
    func makeShell() -> any LaunchGitShell {
        return shell
    }
    
    func makePicker() -> any LaunchPicker {
        return picker
    }
    
    func makeConsoleOutput() -> any ConsoleOutput {
        return MockConsoleOutput()
    }
    
    func makeFileSystem() -> any FileSystem {
        fatalError()
    }
    
    func makeFolderBrowser(picker: any LaunchPicker) -> any DirectoryBrowser {
        fatalError()
    }
    
    func makeContext() throws -> CodeLaunchContext {
        if let context {
            return context
        }

        let defaults = makeDefaults()
        let config = ModelConfiguration(
            "TestModel-\(uniqueId)",
            isStoredInMemoryOnly: true
        )
        let context = try CodeLaunchContext(config: config, defaults: defaults)

        self.context = context

        return context
    }
}


// MARK: - Private
private extension MockContextFactory {
    func makeDefaults() -> UserDefaults {
        let testSuiteName = "testSuiteDefaults-\(uniqueId)"
        let userDefaults = UserDefaults(suiteName: testSuiteName)!
        userDefaults.removePersistentDomain(forName: testSuiteName)

        return userDefaults
    }
}


// MARK: - Mocks

