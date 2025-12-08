////
////  ProjectLinkHandlerTests.swift
////  nnapp
////
////  Created by Nikolai Nobadi on 4/2/25.
////
//
//import Testing
//import SwiftPickerTesting
//@testable import nnapp
//
//struct ProjectLinkHandlerTests {
//    @Test("Returns empty when user declines custom link prompt")
//    func returnsEmptyWhenUserDeclinesCustomLinkPrompt() {
//        let sut = makeSUT(permissionResults: [false])
//        let links = sut.getOtherLinks()
//
//        #expect(links.isEmpty)
//    }
//
//    @Test("Collects link from freeform inputs when no options exist")
//    func collectsLinkFromFreeformInputsWhenNoOptionsExist() {
//        let sut = makeSUT(inputResults: ["Docs", "https://docs.example"], permissionResults: [true, false])
//        let links = sut.getOtherLinks()
//
//        #expect(links == [.init(name: "Docs", urlString: "https://docs.example")])
//    }
//
//    @Test("Uses existing link option when selected")
//    func usesExistingLinkOptionWhenSelected() {
//        let sut = makeSUT(
//            linkOptions: ["Docs", "API"],
//            inputResults: ["https://api.example"],
//            permissionResults: [true, false],
//            selectionIndex: 2
//        )
//
//        let links = sut.getOtherLinks()
//
//        #expect(links == [.init(name: "API", urlString: "https://api.example")])
//    }
//
//    @Test("Prompts for custom name when selecting custom option")
//    func promptsForCustomNameWhenSelectingCustomOption() {
//        let sut = makeSUT(
//            linkOptions: ["Docs", "API"],
//            inputResults: ["Docs", "https://docs.example"],
//            permissionResults: [true, false],
//            selectionIndex: 0
//        )
//
//        let links = sut.getOtherLinks()
//
//        #expect(links == [.init(name: "Docs", urlString: "https://docs.example")])
//    }
//
//    @Test("Returns empty when name or URL input is missing")
//    func returnsEmptyWhenNameOrURLInputIsMissing() {
//        let sut = makeSUT(inputResults: ["", ""], permissionResults: [true])
//        let links = sut.getOtherLinks()
//
//        #expect(links.isEmpty)
//    }
//}
//
//
//// MARK: - SUT
//private extension ProjectLinkHandlerTests {
//    func makeSUT(linkOptions: [String] = [], inputResults: [String] = [], permissionResults: [Bool] = [], selectionIndex: Int = 0) -> ProjectLinkHandler {
//        let picker = MockSwiftPicker(
//            inputResult: .init(type: .ordered(inputResults)),
//            permissionResult: .init(defaultValue: true, type: .ordered(permissionResults)),
//            selectionResult: .init(defaultSingle: .index(selectionIndex))
//        )
//        return ProjectLinkHandler(picker: picker, linkOptions: linkOptions)
//    }
//}
