//
//  List.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import ArgumentParser

extension Nnapp {
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: ""
        )
        
        func run() throws {
            let context = try makeContext()
            let categories = try context.loadCategories()
            
            print("\n---------- CodeLaunch ----------", terminator: "\n\n")
            
            if categories.isEmpty {
                print("No Categories")
            } else {
                for category in categories {
                    print(category.name.bold.underline)
                    
                    if category.groups.isEmpty {
                        print("")
                    } else {
                        for group in category.groups {
                            print("\u{2022} \(group.name.bold.addingShortcut(group.shortcut))")
                            
                            if group.projects.isEmpty {
                                print("")
                            } else {
                                for project in group.projects {
                                    print("  - \(project.name.bold.addingShortcut(project.shortcut))")
                                }
                            }
                        }
                    }
                }
            }
            
            print("")
        }
    }
}


// MARK: - Extension Dependencies
fileprivate extension String {
    func addingShortcut(_ shortcut: String?) -> String {
        guard let shortcut else {
            return self
        }
        
        return "\(self), shortcut: \(shortcut)"
    }
}
