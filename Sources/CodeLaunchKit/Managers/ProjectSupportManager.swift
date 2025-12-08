//
//  ProjectSupportManager.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

public struct ProjectSupportManager: ProjectSupportService {
    public init() { }
}


// MARK: - Actions
public extension ProjectSupportManager {
    func projectType(for folder: Directory) throws -> ProjectType {
        if folder.containsFile(named: "Package.swift") {
            return .package
        }

        if folder.subdirectories.contains(where: { $0.extension == "xcodeproj" }) {
            return .project
        }

        throw CodeLaunchError.noProjectInFolder
    }

    func availableProjectFolders(group: LaunchGroup, categoryFolder: Directory) -> [ProjectFolderCandidate] {
        return categoryFolder.subdirectories.compactMap { subFolder in
            guard
                !group.projects.map({ $0.name.lowercased() }).contains(subFolder.name.lowercased()),
                let projectType = try? projectType(for: subFolder)
            else {
                return nil
            }

            return .init(folder: subFolder, type: projectType)
        }
    }

    func desktopProjectFolders(desktop: Directory) -> [ProjectFolderCandidate] {
        return desktop.subdirectories.compactMap { subFolder in
            guard let projectType = try? projectType(for: subFolder) else {
                return nil
            }

            return .init(folder: subFolder, type: projectType)
        }
    }

    func makeLink(name: String, urlString: String) -> ProjectLink? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedURL.isEmpty else {
            return nil
        }

        return .init(name: trimmedName, urlString: trimmedURL)
    }

    func append(_ link: ProjectLink?, to links: [ProjectLink]) -> [ProjectLink] {
        guard let link else { return links }
        return links + [link]
    }
}
