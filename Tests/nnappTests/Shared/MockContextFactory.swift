//
//  MockContextFactory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import SwiftData
import Foundation
import SwiftPicker
@testable import nnapp

final class MockContextFactory {
    private let shell: MockShell
    private let picker: MockPicker
    private let throwCategorySelectorError: Bool
    private var context: CodeLaunchContext?
    
    init(shell: MockShell = .init(), picker: MockPicker = .init(), throwCategorySelectorError: Bool = false) {
        self.shell = shell
        self.picker = picker
        self.throwCategorySelectorError = throwCategorySelectorError
    }
}


// MARK: - ContextFactory
extension MockContextFactory: ContextFactory {
    func makeShell() -> Shell {
        return shell
    }
    
    func makePicker() -> Picker {
        return picker
    }
    
    func makeProjectGroupSelector(picker: Picker, context: CodeLaunchContext) -> ProjectGroupSelector {
        return MockGroupSelector(context: context)
    }
    
    func makeGroupCategorySelector(picker: Picker, context: CodeLaunchContext) -> GroupCategorySelector {
        return MockCategorySelector(context: context)
    }
    
    func makeContext() throws -> CodeLaunchContext {
        if let context {
            return context
        }
        
        let defaults = makeDefaults()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try CodeLaunchContext(config: config, defaults: defaults)
        
        self.context = context
        
        return context
    }
}


// MARK: - Private
private extension MockContextFactory {
    func makeDefaults() -> UserDefaults {
        let testSuiteName = "testSuiteDefaults"
        let userDefaults = UserDefaults(suiteName: testSuiteName)!
        userDefaults.removePersistentDomain(forName: testSuiteName)
        
        return userDefaults
    }
}
