//
//  DefaultContextFactory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import NnShellKit
import SwiftPickerKit

/// Default implementation of the `ContextFactory` protocol used by the `Nnapp` CLI.
/// Provides fully configured dependencies for use across commands.
final class DefaultContextFactory: ContextFactory {
    /// Creates a new instance of the default shell adapter.
    func makeShell() -> any Shell {
        return NnShell()
    }

    /// Returns an instance of the standard interactive picker.
    func makePicker() -> any CommandLinePicker {
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

    /// Returns a selector for choosing a group category during group setup.
    /// - Parameters:
    ///   - picker: A user input prompt utility.
    ///   - context: The persistence context for data access.
    func makeGroupCategorySelector(picker: any CommandLinePicker, context: CodeLaunchContext) -> any GroupCategorySelector {
        return CategoryHandler(picker: picker, context: context)
    }

    /// Returns a selector for choosing a group during project setup.
    /// - Parameters:
    ///   - picker: A user input prompt utility.
    ///   - context: The persistence context for data access.
    func makeProjectGroupSelector(picker: any CommandLinePicker, context: CodeLaunchContext) -> any ProjectGroupSelector {
        let categorySelector = makeGroupCategorySelector(picker: picker, context: context)
        return GroupHandler(picker: picker, context: context, categorySelector: categorySelector)
    }

    /// Creates a branch sync checker for detecting if branches are behind remote.
    /// - Parameter shell: The shell adapter for executing Git commands.
    func makeBranchSyncChecker(shell: any Shell) -> any BranchSyncChecker {
        return DefaultBranchSyncChecker(shell: shell)
    }

    /// Creates a notifier for alerting about branch sync status.
    /// - Parameter shell: The shell adapter for executing system commands.
    func makeBranchStatusNotifier(shell: any Shell) -> any BranchStatusNotifier {
        return DefaultBranchStatusNotifier(shell: shell)
    }
}
