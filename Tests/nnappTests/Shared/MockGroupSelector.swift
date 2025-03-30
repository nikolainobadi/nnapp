//
//  MockGroupSelector.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Foundation
@testable import nnapp

final class MockGroupSelector {
    private let context: CodeLaunchContext
    
    init(context: CodeLaunchContext) {
        self.context = context
    }
}


// MARK: - Selector
extension MockGroupSelector: ProjectGroupSelector {
    func getGroup(named name: String?) throws -> LaunchGroup {
        guard let group = try context.loadGroups().first else {
            throw NSError(domain: "Test", code: 0)
        }
        
        return group
    }
}
