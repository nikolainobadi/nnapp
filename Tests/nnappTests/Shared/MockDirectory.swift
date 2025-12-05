//
//  MockDirectory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Foundation
import CodeLaunchKit

struct MockDirectory: Directory {
    let path: String
    let name: String
    let `extension`: String? = nil
    var subdirectories: [Directory] = []
    
    init(path: String) {
        self.path = path
        self.name = (path as NSString).lastPathComponent
    }
    
    func containsFile(named name: String) -> Bool {
        return false // TODO: - 
    }
    
    func subdirectory(named name: String) throws -> Directory {
        return MockDirectory(path: path.appendingPathComponent(name))
    }
    func createSubdirectory(named name: String) throws -> Directory {
        return try subdirectory(named: name)
    }
    
    func move(to parent: Directory) throws {
        // TODO: -
    }
}
