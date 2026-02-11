//
//  MockDirectory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Foundation
import CodeLaunchKit

final class MockDirectory: Directory {
    let path: String
    let name: String
    let `extension`: String?
    var subdirectories: [Directory]
    var containedFiles: Set<String>
    private let shouldThrowOnSubdirectory: Bool
    private let autoCreateSubdirectories: Bool
    private(set) var movedToParents: [String] = []
    private(set) var deleteCallCount: Int = 0

    init(path: String, subdirectories: [Directory] = [], containedFiles: Set<String> = [], shouldThrowOnSubdirectory: Bool = false, autoCreateSubdirectories: Bool = true, ext: String? = nil) {
        self.path = path
        self.name = (path as NSString).lastPathComponent
        self.subdirectories = subdirectories
        self.containedFiles = containedFiles
        self.shouldThrowOnSubdirectory = shouldThrowOnSubdirectory
        self.autoCreateSubdirectories = autoCreateSubdirectories
        self.extension = ext
    }

    func containsFile(named name: String) -> Bool {
        return containedFiles.contains(name)
    }

    func subdirectory(named name: String) throws -> Directory {
        if shouldThrowOnSubdirectory {
            throw NSError(domain: "MockDirectory", code: 1)
        }

        if let match = subdirectories.first(where: { $0.name == name }) {
            return match
        }

        if autoCreateSubdirectories {
            return MockDirectory(path: path.appendingPathComponent(name))
        }

        throw NSError(domain: "MockDirectory", code: 2)
    }

    func createSubdirectory(named name: String) throws -> Directory {
        return try subdirectory(named: name)
    }

    func move(to parent: Directory) throws {
        movedToParents.append(parent.path)
    }

    func delete() throws {
        deleteCallCount += 1
    }
}
