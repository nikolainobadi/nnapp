//
//  Remove.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

extension Nnapp {
    struct Remove: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
    }
}


// MARK: - Category
extension Nnapp.Remove {
    struct Category: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        func run() throws {
            // TODO: - 
        }
    }
}

// MARK: - Group
extension Nnapp.Remove {
    struct Group: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        func run() throws {
            // TODO: -
        }
    }
}

// MARK: - Project
extension Nnapp.Remove {
    struct Project: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        func run() throws {
            // TODO: -
        }
    }
}
