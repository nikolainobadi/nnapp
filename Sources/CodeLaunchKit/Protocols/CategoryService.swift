//
//  CategoryService.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol CategoryService {
    func loadCategories() throws -> [LaunchCategory]
    func deleteCategory(_ category: LaunchCategory) throws
    func category(for group: LaunchGroup) -> LaunchCategory?
    
    @discardableResult
    func importCategory(from folder: Directory) throws -> LaunchCategory
    @discardableResult
    func createCategory(named name: String, in parentFolder: Directory) throws -> LaunchCategory
}
