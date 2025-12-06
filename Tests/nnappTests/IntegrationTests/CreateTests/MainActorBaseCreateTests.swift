////
////  MainActorBaseCreateTests.swift
////  nnapp
////
////  Created by Nikolai Nobadi on 3/29/25.
////
//
//import Testing
//@testable import nnapp
//
//@MainActor
//class MainActorBaseCreateTests: MainActorTempFolderDatasource {
//    enum ArgType {
//        case category(name: String?, parentPath: String?)
//        case group(name: String?, category: String?)
//    }
//    
//    struct TestInfo {
//        let name: ArgOrInput
//        let otherArg: ArgOrInput
//        
//        enum ArgOrInput {
//            case arg, input
//        }
//        
//        static var testOptions: [TestInfo] {
//            return [
//                TestInfo(name: .input, otherArg: .input),
//                TestInfo(name: .arg, otherArg: .input),
//                TestInfo(name: .arg, otherArg: .arg),
//                TestInfo(name: .input, otherArg: .arg)
//            ]
//        }
//    }
//    
//    func runCommand(_ factory: MockContextFactory?, argType: ArgType?) throws {
//        var args = ["create"]
//        
//        if let argType {
//            switch argType {
//            case .category(let name, let parentPath):
//                args.append("category")
//                
//                if let name {
//                    args.append(name)
//                }
//                
//                if let parentPath {
//                    args.append(contentsOf: ["-p", parentPath])
//                }
//                
//            case .group(let name, let category):
//                args.append("group")
//                
//                if let name {
//                    args.append(name)
//                }
//                
//                if let category {
//                    args.append(contentsOf: ["-c", category])
//                }
//            }
//        }
//        
//        try Nnapp.testRun(contextFactory: factory, args: args)
//    }
//}
