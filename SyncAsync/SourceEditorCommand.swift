//
//  SourceEditorCommand.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 07.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation
import XcodeKit

let StandardIndentation = "    "

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    lazy var swiftCreator = SwiftFunctionCreator()
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void
    {
        let selection = invocation.buffer.selections[0] as! XCSourceTextRange
        let funcSignatureLine: String = invocation.buffer.lines[selection.start.line] as! String
        if funcSignatureLine.contains("func")
        {
            swiftCreator.createSyncFunction(buffer: invocation.buffer, startLineIndex: selection.start.line, completionHandler: completionHandler)
        }
        else if funcSignatureLine.contains("(void)")
        {
            completionHandler(ObjcError)
        }
        completionHandler(DefaultError)
    }
}
