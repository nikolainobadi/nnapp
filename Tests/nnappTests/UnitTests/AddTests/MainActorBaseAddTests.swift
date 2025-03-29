//
//  MainActorBaseAddTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

@testable import nnapp

@MainActor
class MainActorBaseAddTests: MainActorTempFolderDatasource {
    enum ArgType {
        case category(path: String?)
        case group(path: String?, category: String?)
    }
    
    func runCommand(_ factory: MockContextFactory? = nil, argType: ArgType) throws {
        var args = ["add"]
        
        switch argType {
        case .category(let path):
            args.append("category")
            
            if let path {
                args.append(path)
            }
        case .group(let path, let category):
            args.append("group")
            
            if let path {
                args.append(path)
            }
            
            if let category {
                args.append(contentsOf: ["-c", category])
            }
        }
        
        try Nnapp.testRun(contextFactory: factory, args: args)
    }
}
