//
//  DefaultContextFactory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import SwiftPicker

/// Default implementation of the `ContextFactory` protocol used by the `Nnapp` CLI.
/// Provides fully configured dependencies for use across commands.
final class DefaultContextFactory: ContextFactory {
    /// Creates a new instance of the default shell adapter.
    func makeShell() -> Shell {
        return DefaultShell()
    }

    /// Returns an instance of the standard interactive picker.
    func makePicker() -> Picker {
        return SwiftPicker()
    }

    /// Creates the primary persistence context used for saving/loading data.
    func makeContext() throws -> CodeLaunchContext {
        return try CodeLaunchContext()
    }

    /// Returns a selector for choosing a group category during group setup.
    /// - Parameters:
    ///   - picker: A user input prompt utility.
    ///   - context: The persistence context for data access.
    func makeGroupCategorySelector(picker: Picker, context: CodeLaunchContext) -> GroupCategorySelector {
        return CategoryHandler(picker: picker, context: context)
    }

    /// Returns a selector for choosing a group during project setup.
    /// - Parameters:
    ///   - picker: A user input prompt utility.
    ///   - context: The persistence context for data access.
    func makeProjectGroupSelector(picker: Picker, context: CodeLaunchContext) -> ProjectGroupSelector {
        let categorySelector = makeGroupCategorySelector(picker: picker, context: context)
        return GroupHandler(picker: picker, context: context, categorySelector: categorySelector)
    }
}
