//
//  ProjectLinkHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 4/2/25.
//

import Testing
import SwiftPickerTesting
@testable import nnapp

struct ProjectLinkHandlerTests {
    @Test("Returns empty when user declines custom link prompt")
    func returnsEmptyWhenUserDeclinesCustomLinkPrompt() {
        let (sut, picker) = makeSUT(permissionResults: [false])
        let links = sut.getOtherLinks()

        #expect(links.isEmpty)
        #expect(picker.capturedPermissionPrompts == ["Would you like to add a custom link?"])
        #expect(picker.capturedPrompts.isEmpty)
    }

    @Test("Collects link from freeform inputs when no options exist")
    func collectsLinkFromFreeformInputsWhenNoOptionsExist() {
        let (sut, picker) = makeSUT(inputResults: ["Docs", "https://docs.example"], permissionResults: [true, false])

        let links = sut.getOtherLinks()

        #expect(links == [.init(name: "Docs", urlString: "https://docs.example")])
        #expect(picker.capturedPermissionPrompts.count == 2)
        #expect(picker.capturedPrompts.contains("Enter the name (NOT url) of your new link. (exmple: website, Firebase Firestore, etc)"))
        #expect(picker.capturedPrompts.contains("Enter the url for your Docs link."))
    }

    @Test("Uses existing link options when user selects one")
    func usesExistingLinkOptionsWhenUserSelectsOne() {
        let (sut, picker) = makeSUT(
            linkOptions: ["Docs", "API"],
            inputResults: ["https://api.example"],
            permissionResults: [true, false],
            selectionIndex: 2
        )

        let links = sut.getOtherLinks()

        #expect(links == [.init(name: "API", urlString: "https://api.example")])
        #expect(picker.capturedSingleSelectionPrompts.contains("What name would you like to use for your link?"))
        #expect(picker.capturedPrompts.contains("Enter the url for your API link."))
    }

    @Test("Prompts for custom name when selecting custom option")
    func promptsForCustomNameWhenSelectingCustomOption() {
        let (sut, picker) = makeSUT(
            linkOptions: ["Docs", "API"],
            inputResults: ["Docs", "https://docs.example"],
            permissionResults: [true, false]
        )

        let links = sut.getOtherLinks()

        #expect(links == [.init(name: "Docs", urlString: "https://docs.example")])
        #expect(picker.capturedPrompts.contains("Enter the name (NOT url) of your new link. (exmple: website, Firebase Firestore, etc)"))
        #expect(picker.capturedPrompts.contains("Enter the url for your Docs link."))
    }

    @Test("Returns empty when name or URL input is missing")
    func returnsEmptyWhenNameOrURLInputIsMissing() {
        let (sut, picker) = makeSUT(inputResults: ["", ""])

        let links = sut.getOtherLinks()

        #expect(links.isEmpty)
        #expect(picker.capturedPermissionPrompts.count == 1)
    }
}


// MARK: - SUT
private extension ProjectLinkHandlerTests {
    func makeSUT(linkOptions: [String] = [], inputResults: [String] = [], permissionResults: [Bool] = [], selectionIndex: Int = 0) -> (sut: ProjectLinkHandler, picker: MockSwiftPicker) {
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(defaultValue: true, type: .ordered(permissionResults)),
            selectionResult: .init(defaultSingle: .index(selectionIndex))
        )
        let sut = ProjectLinkHandler(picker: picker, linkOptions: linkOptions)

        return (sut, picker)
    }
}
