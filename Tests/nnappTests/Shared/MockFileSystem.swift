//
//  MockFileSystem.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Foundation
import CodeLaunchKit

final class MockFileSystem: FileSystem {
    private let desktop: any Directory
    private let directoryToLoad: (any Directory)?
    private let directoryMap: [String: any Directory]?

    private(set) var capturedPaths: [String] = []

    let homeDirectory: any Directory

    init(homeDirectory: any Directory = MockDirectory(path: "/Users/test"), directoryToLoad: (any Directory)? = nil, directoryMap: [String: any Directory]? = nil, desktop: (any Directory)? = nil) {
        self.homeDirectory = homeDirectory
        self.directoryToLoad = directoryToLoad
        self.directoryMap = directoryMap
        self.desktop = desktop ?? MockDirectory(path: homeDirectory.path.appendingPathComponent("Desktop"))
    }

    func directory(at path: String) throws -> any Directory {
        capturedPaths.append(path)

        if let directoryMap, let directory = directoryMap[path] {
            return directory
        }

        if let directoryToLoad {
            return directoryToLoad
        }

        throw NSError(domain: "MockFileSystem", code: 1)
    }

    func desktopDirectory() throws -> any Directory {
        return desktop
    }
}
