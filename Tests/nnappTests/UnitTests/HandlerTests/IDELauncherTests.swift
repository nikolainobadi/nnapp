//
//  IDELauncherTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import Foundation
import CodeLaunchKit
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

struct IDELauncherTests {
    
}


// MARK: - SUT
private extension IDELauncherTests {
    func makeSUT() -> (sut: IDELauncher, shell: MockShell, picker: MockSwiftPicker) {
        let shell = MockShell()
        let picker = MockSwiftPicker()
        let sut = IDELauncher(shell: shell, picker: picker)
        
        return (sut, shell, picker)
    }
}
