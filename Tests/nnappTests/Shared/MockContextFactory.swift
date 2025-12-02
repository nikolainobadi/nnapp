//
//  MockContextFactory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import SwiftData
import Foundation
import NnShellKit
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
    
    init(shell: MockShell = .init(), picker: MockSwiftPicker = .init(), throwCategorySelectorError: Bool = false) {
        self.shell = shell
        self.picker = picker
        self.throwCategorySelectorError = throwCategorySelectorError
        self.uniqueId = UUID().uuidString
    }
}


// MARK: - ContextFactory
extension MockContextFactory: ContextFactory {
    func makeShell() -> any Shell {
        return shell
    }
    
    func makePicker() -> any CommandLinePicker {
        return picker
    }
    
    func makeProjectGroupSelector(picker: any CommandLinePicker, context: CodeLaunchContext) -> any ProjectGroupSelector {
        return MockGroupSelector(context: context)
    }
    
    func makeGroupCategorySelector(picker: any CommandLinePicker, context: CodeLaunchContext) -> any GroupCategorySelector {
        return MockCategorySelector(context: context)
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
