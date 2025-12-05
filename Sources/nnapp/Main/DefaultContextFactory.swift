//
//  DefaultContextFactory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import NnShellKit
import Foundation
import CodeLaunchKit
import SwiftPickerKit

final class DefaultContextFactory: ContextFactory {
    func makeShell() -> any LaunchShell {
        return NnShell()
    }

    func makePicker() -> any LaunchPicker {
        return SwiftPicker()
    }

    func makeContext() throws -> CodeLaunchContext {
        return try CodeLaunchContext()
    }

    func makeConsoleOutput() -> any ConsoleOutput {
        return DefaultConsoleOutput()
    }

    func makeFileSystem() -> any FileSystem {
        return DefaultFileSystem()
    }

    func makeFolderBrowser(picker: any LaunchPicker) -> any FolderBrowser {
        return DefaultFolderBrowser(
            picker: picker,
            fileSystem: makeFileSystem(),
            homeDirectoryURL: FileManager.default.homeDirectoryForCurrentUser
        )
    }

    func makeBranchSyncChecker(shell: any LaunchShell) -> any BranchSyncChecker {
        return DefaultBranchSyncChecker(shell: shell)
    }

    func makeBranchStatusNotifier(shell: any LaunchShell) -> any BranchStatusNotifier {
        return DefaultBranchStatusNotifier(shell: shell)
    }
}
