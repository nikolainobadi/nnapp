//
//  MockDirectoryBrowser.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Foundation
import CodeLaunchKit

final class MockDirectoryBrowser: DirectoryBrowser {
    var selectedDirectory: (any Directory)?

    private(set) var prompt: String?

    init(selectedDirectory: (any Directory)? = nil) {
        self.selectedDirectory = selectedDirectory
    }

    func browseForDirectory(prompt: String) throws -> any Directory {
        self.prompt = prompt

        guard let selectedDirectory else {
            throw NSError(domain: "Test", code: 0)
        }

        return selectedDirectory
    }
}
