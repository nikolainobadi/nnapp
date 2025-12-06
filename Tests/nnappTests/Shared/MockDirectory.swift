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
    let `extension`: String?
    var subdirectories: [Directory]
    var containedFiles: Set<String>

    init(path: String, subdirectories: [Directory] = [], containedFiles: Set<String> = [], ext: String? = nil) {
        self.path = path
        self.name = (path as NSString).lastPathComponent
        self.subdirectories = subdirectories
        self.containedFiles = containedFiles
        self.extension = ext
    }

    func containsFile(named name: String) -> Bool {
        return containedFiles.contains(name)
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
