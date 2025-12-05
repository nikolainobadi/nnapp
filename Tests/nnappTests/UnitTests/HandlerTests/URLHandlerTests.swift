//
//  URLHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import CodeLaunchKit
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

struct URLHandlerTests {
    
}

// MARK: - SUT
private extension URLHandlerTests {
    func makeSUT() -> (sut: URLHandler, shell: MockShell) {
        let shell = MockShell()
        let picker = MockSwiftPicker()
        let sut = URLHandler(shell: shell, picker: picker)
        
        return (sut, shell)
    }
}
