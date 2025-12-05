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

/// Default implementation of the `ContextFactory` protocol used by the `Nnapp` CLI.
/// Provides fully configured dependencies for use across commands.
final class DefaultContextFactory: ContextFactory {
    /// Creates a new instance of the default shell adapter.
    func makeShell() -> any LaunchShell {
        return NnShell()
    }

    /// Returns an instance of the standard interactive picker.
    func makePicker() -> any LaunchPicker {
        return SwiftPicker()
    }

    /// Creates the primary persistence context used for saving/loading data.
    func makeContext() throws -> CodeLaunchContext {
        return try CodeLaunchContext()
    }

    /// Creates a console output adapter for displaying information to the user.
    func makeConsoleOutput() -> any ConsoleOutput {
        return DefaultConsoleOutput()
    }

    /// Provides the default file system implementation backed by `Files`.
    func makeFileSystem() -> any FileSystem {
        return DefaultFileSystem()
    }

    /// Creates a folder browser for selecting folders via tree navigation.
    /// - Parameter picker: Picker used to drive the interactive browsing experience.
    func makeFolderBrowser(picker: any LaunchPicker) -> any FolderBrowser {
        return DefaultFolderBrowser(picker: picker, homeDirectoryURL: FileManager.default.homeDirectoryForCurrentUser)
    }

    /// Creates a branch sync checker for detecting if branches are behind remote.
    /// - Parameter shell: The shell adapter for executing Git commands.
    func makeBranchSyncChecker(shell: any LaunchShell) -> any BranchSyncChecker {
        return DefaultBranchSyncChecker(shell: shell)
    }

    /// Creates a notifier for alerting about branch sync status.
    /// - Parameter shell: The shell adapter for executing system commands.
    func makeBranchStatusNotifier(shell: any LaunchShell) -> any BranchStatusNotifier {
        return DefaultBranchStatusNotifier(shell: shell)
    }
}
