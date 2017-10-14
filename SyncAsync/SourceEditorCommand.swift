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
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void
    {
        let selection = invocation.buffer.selections[0] as! XCSourceTextRange
        let funcSignatureLine: String = invocation.buffer.lines[selection.start.line] as! String
        if funcSignatureLine.contains("func")
        {
            swift(buffer: invocation.buffer, startLineIndex: selection.start.line, completionHandler: completionHandler)
        }
        else if funcSignatureLine.contains("(void)")
        {
            objectiveC(completionHandler: completionHandler)
        }
        completionHandler(DefaultError)
    }
    
    func swift(buffer: XCSourceTextBuffer, startLineIndex: Int, completionHandler: @escaping (Error?) -> Void)
    {
        let parser = SwiftFileParser(buffer: buffer.completeBuffer)
        guard let funcElements = try? parser.getFuncElements(startLineIndex: startLineIndex) else
        {
            completionHandler(DefaultError)
            return
        }
        let closures = funcElements.params.filter({ (param) -> Bool in
            return isSwiftEscapingClosure(type: param.type)
        })
        if closures.count == 0 || closures.count > 2
        {
            completionHandler(DefaultError)
            return
        }
        var result = "\n"
        var funcIndentation = ""
        for _ in 0..<buffer.indentationWidth
        {
            funcIndentation += " "
        }
        result += "\(funcIndentation)\(funcElements.attribs) \(funcElements.name)Sync("
        for i in 0..<funcElements.params.count
        {
            let param = funcElements.params[i]
            if !isSwiftEscapingClosure(type: param.type)
            {
                if i > 0
                {
                    result += ", "
                }
                result += param.body
            }
        }
        guard let firstLineIndentation = try? SwiftFileParser.getFuncFirstLineIndentation(funcBody: funcElements.body) else {
            completionHandler(DefaultError)
            return
        }
        let newBody = createNewFuncBodySwift(firstLineIndentation: firstLineIndentation, funcName: funcElements.name, params: funcElements.params)
        result += ")\(funcElements.postAttribs){\n\(newBody)\n\(funcIndentation)}"
        
        if buffer.lines.count == funcElements.endLineIndex-1
        {
            buffer.lines.add("")
        }
        buffer.lines.insert(result, at: funcElements.endLineIndex+1)
        completionHandler(nil)
    }
    
    private func isSwiftEscapingClosure(type: SwiftType) -> Bool
    {
        if let closure = type as? SwiftClosure {
            return closure.isEscaping
        }
        return false
    }
    
    private func createNewFuncBodySwift(firstLineIndentation: String, funcName: String, params: [SwiftParam]) -> String
    {
        var result = "\(firstLineIndentation)let semaphore = DispatchSemaphore(value: 0)"
        result += "\n\(firstLineIndentation)\(funcName)("
        
        for i in 0..<params.count
        {
            let param = params[i]
            if i > 0
            {
                result += ", "
            }
            if isSwiftEscapingClosure(type: param.type)
            {
                result += "\(param.name!): {"
                let closure = param.type as! SwiftClosure
                if closure.params.count > 0
                {
                    result += " ("
                    for j in 0..<closure.params.count
                    {
                        let p = closure.params[j]
                        if j > 0
                        {
                            result += ", "
                        }
                        result += p.name ?? closure.body
                    }
                    result += ") in"
                }
                // return
//                result += "\n\(firstLineIndentation)return"
//                if param.params.count > 0
//                {
//                for j in 0..<param.params.count
//                {
//                    let p = param.params[j]
//                    if j > 0
//                    {
//                        result += ", "
//                    }
//                    result += "\(p.name): \(p.name)"
//                }
//                result += ")"
                result += "\n\(firstLineIndentation)\(StandardIndentation)semaphore.signal()"
//                }
                result += "\n\(firstLineIndentation)}"
            }
            else
            {
                result += "\(param.name!): \(param.name!)"
            }
        }
        result += ")"
        result += "\n\(firstLineIndentation)semaphore.wait(timeout: DispatchTime.distantFuture)"
        return result
    }
    
    func objectiveC(completionHandler: @escaping (Error?) -> Void )
    {
        completionHandler(DefaultError)
    }
    
}
