//
//  MockFileSystem.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Foundation
import CodeLaunchKit

final class MockFileSystem: FileSystem {
    private let desktop: MockDirectory
    private let directoryToLoad: MockDirectory?

    private(set) var capturedPaths: [String] = []

    let homeDirectory: any Directory

    init(homeDirectory: MockDirectory = .init(path: "/Users/test"), directoryToLoad: MockDirectory? = nil, desktop: MockDirectory? = nil) {
        self.homeDirectory = homeDirectory
        self.directoryToLoad = directoryToLoad
        self.desktop = desktop ?? .init(path: homeDirectory.path.appendingPathComponent("Desktop"))
    }

    func directory(at path: String) throws -> any Directory {
        capturedPaths.append(path)

        if let directoryToLoad {
            return directoryToLoad
        }

        throw NSError(domain: "MockFileSystem", code: 1)
    }

    func desktopDirectory() throws -> any Directory {
        return desktop
    }
}
