//
//  MockContextFactory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Files
import SwiftData
import Foundation
import NnShellKit
import CodeLaunchKit
import SwiftPickerKit
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

final class MockContextFactory {
    private let shell: MockShell
    private let picker: MockSwiftPicker
    private let throwCategorySelectorError: Bool
    private var context: CodeLaunchContext?
    private let uniqueId: String
    private let branchSyncChecker: (any BranchSyncChecker)?
    private let branchStatusNotifier: (any BranchStatusNotifier)?
    private let folderBrowser: any DirectoryBrowser

    init(shell: MockShell = .init(), picker: MockSwiftPicker = .init(), throwCategorySelectorError: Bool = false, branchSyncChecker: (any BranchSyncChecker)? = nil, branchStatusNotifier: (any BranchStatusNotifier)? = nil, folderBrowser: (any DirectoryBrowser)? = nil) {
        self.shell = shell
        self.picker = picker
        self.throwCategorySelectorError = throwCategorySelectorError
        self.uniqueId = UUID().uuidString
        self.branchSyncChecker = branchSyncChecker
        self.branchStatusNotifier = branchStatusNotifier
        self.folderBrowser = folderBrowser ?? MockFolderBrowser()
    }
}


// MARK: - ContextFactory
extension MockContextFactory: ContextFactory {
    func makeFileSystem() -> any FileSystem {
        fatalError()
    }
    
    func makeFolderBrowser(picker: any LaunchPicker) -> any DirectoryBrowser {
        fatalError()
    }
    
    func makeBranchSyncChecker(shell: any LaunchShell) -> any BranchSyncChecker {
        fatalError()
    }
    
    func makeBranchStatusNotifier(shell: any LaunchShell) -> any BranchStatusNotifier {
        fatalError()
    }
    
    func makeShell() -> any LaunchShell {
        return shell
    }
    
    func makePicker() -> any LaunchPicker {
        return picker
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

    func makeConsoleOutput() -> any ConsoleOutput {
        return MockConsoleOutput()
    }

    func makeFolderBrowser(picker: any CommandLinePicker) -> any DirectoryBrowser {
        return folderBrowser
    }

    func makeBranchSyncChecker(shell: any Shell) -> any BranchSyncChecker {
        return branchSyncChecker ?? MockBranchSyncChecker()
    }

    func makeBranchStatusNotifier(shell: any Shell) -> any BranchStatusNotifier {
        return branchStatusNotifier ?? MockBranchStatusNotifier()
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
final class MockBranchSyncChecker: BranchSyncChecker {
    private(set) var checkCallCount = 0
    private(set) var lastProject: LaunchProject?
    var result: LaunchBranchStatus?

    func checkBranchSyncStatus(for project: LaunchProject) -> LaunchBranchStatus? {
        checkCallCount += 1
        lastProject = project
        return result
    }
}

final class MockBranchStatusNotifier: BranchStatusNotifier {
    private(set) var notifyCallCount = 0
    private(set) var lastStatus: LaunchBranchStatus?
    private(set) var lastProject: LaunchProject?

    func notify(status: LaunchBranchStatus, for project: LaunchProject) {
        notifyCallCount += 1
        lastStatus = status
        lastProject = project
    }
}

final class MockFolderBrowser: DirectoryBrowser {
    private(set) var browseCallCount = 0
    private(set) var capturedPrompt: String?
    private(set) var capturedStartPath: String?
    var folderToReturn: Directory?
    var error: Error?

    func browseForDirectory(prompt: String, startPath: String?) throws -> Directory {
        fatalError()
//        browseCallCount += 1
//        capturedPrompt = prompt
//        capturedStartPath = startPath
//
//        if let error {
//            throw error
//        }
//
//        if let folderToReturn {
//            return folderToReturn
//        }
//
//        let folder = try Folder.temporary.createSubfolder(named: "MockFolderBrowser-\(UUID().uuidString)")
//        return FilesDirectoryAdapter(folder: folder)
    }
}
