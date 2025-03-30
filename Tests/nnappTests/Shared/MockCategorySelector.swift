//
//  FiMockCategorySelectorle.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Foundation
@testable import nnapp

final class MockCategorySelector {
    private let context: CodeLaunchContext
    
    init(context: CodeLaunchContext) {
        self.context = context
    }
}


// MARK: - Selector
extension MockCategorySelector: GroupCategorySelector {
    func getCategory(named name: String?) throws -> LaunchCategory {
        guard let category = try context.loadCategories().first else {
            throw NSError(domain: "Test", code: 0)
        }
        
        return category
    }
}
