//
//  CategoryManager.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public struct CategoryManager: CategoryService {
    private let store: any CategoryStore

    public init(store: any CategoryStore) {
        self.store = store
    }
}


// MARK: - Actions
public extension CategoryManager {
    func loadCategories() throws -> [LaunchCategory] {
        return try store.loadCategories()
    }

    @discardableResult
    func importCategory(from folder: Directory) throws -> LaunchCategory {
        let categories = try loadCategories()
        let name = try validateName(folder.name, categories: categories)

        return try saveCategory(.new(name: name, path: folder.path))
    }

    @discardableResult
    func createCategory(named name: String, in parentFolder: Directory) throws -> LaunchCategory {
        let categories = try loadCategories()
        let validatedName = try validateName(name, categories: categories)

        try validateParentFolder(parentFolder, categoryName: validatedName)
        let categoryFolder = try parentFolder.createSubdirectory(named: validatedName)

        return try saveCategory(.new(name: validatedName, path: categoryFolder.path))
    }

    func deleteCategory(_ category: LaunchCategory) throws {
        try store.deleteCategory(category)
    }

    func category(for group: LaunchGroup) -> LaunchCategory? {
        guard let categories = try? loadCategories() else {
            return nil
        }

        return categories.first(where: { category in
            category.groups.contains(where: { $0.name.matches(group.name) })
        })
    }
}


// MARK: - Private Methods
private extension CategoryManager {
    func validateName(_ name: String, categories: [LaunchCategory]) throws -> String {
        if categories.contains(where: { $0.name.matches(name) }) {
            throw CodeLaunchError.categoryNameTaken
        }

        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func validateParentFolder(_ folder: Directory, categoryName: String) throws {
        if folder.subdirectories.contains(where: { $0.name.matches(categoryName) }) {
            throw CodeLaunchError.categoryPathTaken
        }
    }

    func saveCategory(_ category: LaunchCategory) throws -> LaunchCategory {
        try store.saveCategory(category)
        return category
    }
}
