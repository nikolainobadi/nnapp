//
//  ProcessInfoEnvironmentProvider.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/6/25.
//

import Foundation

struct ProcessInfoEnvironmentProvider: TerminalEnvironmentProviding {
    func termProgram() -> String? {
        return ProcessInfo.processInfo.environment["TERM_PROGRAM"]
    }
}
