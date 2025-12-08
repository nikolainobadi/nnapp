//
//  GroupService.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public protocol GroupService {
    func loadGroups() throws -> [LaunchGroup]
    func loadCategories() throws -> [LaunchCategory]
    func validateName(_ name: String, groups: [LaunchGroup]) throws -> String
    func deleteGroup(_ group: LaunchGroup) throws
    func projectGroup(for project: LaunchProject) throws -> LaunchGroup?
    func mainProject(in group: LaunchGroup) -> LaunchProject?
    func nonMainProjects(in group: LaunchGroup, excluding currentMain: LaunchProject?) -> [LaunchProject]
    func shouldClearPreviousShortcut(group: LaunchGroup, shortcutToUse: String) -> Bool
    func persistMainProjectChange(group: LaunchGroup, currentMain: LaunchProject?, newMain: LaunchProject, shortcut: String) throws
    
    @discardableResult
    func saveGroup(_ group: LaunchGroup, in category: LaunchCategory, groupFolder: Directory?, categoryFolder: Directory?) throws -> LaunchGroup
}
