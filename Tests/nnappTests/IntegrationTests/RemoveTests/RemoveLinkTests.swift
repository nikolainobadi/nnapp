//
//  RemoveLinkTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
import SwiftPickerTesting
@testable import nnapp

@MainActor
final class RemoveLinkTests: MainActorBaseRemoveTests {
    @Test("Prints message when no links exist")
    func noLinksToRemove() throws {
        let factory = MockContextFactory()
        let output = try Nnapp.testRun(contextFactory: factory, args: ["remove", "link"])
        #expect(output.contains("No Project Links to remove"))
    }

    @Test("Removes selected link")
    func removesSelectedLink() throws {
        let picker = MockSwiftPicker(selectionResult: .init(defaultSingle: .index(0)))
        let factory = MockContextFactory(picker: picker)
        let context = try factory.makeContext()
        context.saveProjectLinkNames(["One", "Two"])

        try runLinkCommand(factory)

        let updated = context.loadProjectLinkNames()
        #expect(updated == ["Two"])
    }
}


// MARK: - Run
@MainActor
private func runLinkCommand(_ factory: MockContextFactory? = nil) throws {
    try MainActorBaseRemoveTests.runRemoveCommand(factory, argType: .link)
}
