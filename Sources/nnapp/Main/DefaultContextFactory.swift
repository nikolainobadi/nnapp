//
//  DefaultContextFactory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import SwiftPicker

final class DefaultContextFactory: ContextFactory {
    func makeShell() -> Shell {
        return DefaultShell()
    }
    
    func makePicker() -> Picker {
        return SwiftPicker()
    }
    
    func makeContext() throws -> CodeLaunchContext {
        return try CodeLaunchContext()
    }
    
    func makeGroupCategorySelector(picker: Picker, context: CodeLaunchContext) -> GroupCategorySelector {
        return CategoryHandler(picker: picker, context: context)
    }
    
    func makeProjectGroupSelector(picker: Picker, context: CodeLaunchContext) -> ProjectGroupSelector {
        let categorySelector = makeGroupCategorySelector(picker: picker, context: context)
        
        return GroupHandler(picker: picker, context: context, categorySelector: categorySelector)
    }
}
