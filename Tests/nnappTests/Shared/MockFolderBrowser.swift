//
//  MockFolderBrowser.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Foundation
import CodeLaunchKit

final class MockFolderBrowser: DirectoryBrowser {
    private let selectedDirectory: MockDirectory?
    
    private(set) var prompt: String?
    private(set) var startPath: String?
    
    init(selectedDirectory: MockDirectory?) {
        self.selectedDirectory = selectedDirectory
    }

    func browseForDirectory(prompt: String, startPath: String?) throws -> any Directory {
        self.prompt = prompt
        self.startPath = startPath
        
        if let selectedDirectory {
            return selectedDirectory
        }
        
        throw NSError(domain: "Test", code: 0)
    }
}
