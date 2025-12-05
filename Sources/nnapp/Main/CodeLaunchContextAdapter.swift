//
//  CodeLaunchContextAdapter.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

final class CodeLaunchContextAdapter {
    private let context: CodeLaunchContext
    
    init(context: CodeLaunchContext) {
        self.context = context
    }
}


// MARK: -
extension CodeLaunchContextAdapter: LaunchListLoader, FinderInfoLoader {
    func loadCategories() throws -> [LaunchCategory] {
        return [] // TODO: -
    }
    
    func loadGroups() throws -> [LaunchGroup] {
        return [] // TODO: -
    }
    func loadProjects() throws -> [LaunchProject] {
        return [] // TODO: -
    }
    
    func loadProjectLinkNames() -> [String] {
        return [] // TODO: - 
    }
}
