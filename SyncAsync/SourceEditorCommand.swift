//
//  SourceEditorCommand.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 07.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    lazy var swiftFunctionCreator = SwiftFunctionCreator()
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void
    {
        let selection = invocation.buffer.selections[0] as! XCSourceTextRange
        let funcSignatureLine: String = invocation.buffer.lines[selection.start.line] as! String
        if funcSignatureLine.contains("func")
        {
            createSyncFunction(buffer: invocation.buffer, startLineIndex: selection.start.line, completionHandler: completionHandler)
        }
        else if funcSignatureLine.contains("(void)")
        {
            completionHandler(ObjcError)
        }
        completionHandler(DefaultError)
    }
    
    func createSyncFunction(buffer: XCSourceTextBuffer, startLineIndex: Int, completionHandler: @escaping (Error?) -> Void)
    {
        let parser = SwiftFileParser(buffer: buffer.completeBuffer)
        guard let funcElements = try? parser.getFuncElements(startLineIndex: startLineIndex) else {
            completionHandler(DefaultError)
            return
        }
        
        if funcElements.postAttribs.contains(where: { (char) -> Bool in
            return !CharacterSet.whitespacesAndNewlines.contains(char.unicodeScalars.first!)
        }) {
            completionHandler(DefaultError)
            return
        }
        
        var closures = funcElements.params.filter({ (param) -> Bool in
            return swiftFunctionCreator.isSwiftEscapingClosure(type: param.type)
        })
        if closures.count == 0 || closures.count > 2
        {
            completionHandler(DefaultError)
            return
        }
        for i in 0..<closures.count
        {
            let closure = closures[i]
            guard let type = closure.type as? SwiftClosure else {
                completionHandler(DefaultError)
                return
            }
            if closure.name!.contains("error") || (closure.type.body.contains("Error") && !closure.type.body.contains("("))
            {
                closure.isErrorClosure = true
                break
            }
            for i in 0..<type.params.count
            {
                let param = type.params[i]
                if param.name == "error" || param.type.body.contains("Error")
                {
                    closure.closureErrorParamIndex = i
                    break
                }
            }
        }
        let returnType = swiftFunctionCreator.getReturnType(closures: closures)
        var postAttribs = returnType == SwiftType.Void() ? "" : " -> \(returnType.body)"
        postAttribs = postAttribs + funcElements.postAttribs
        
        let isThrowing = closures.contains { (closure) -> Bool in
            return closure.isErrorClosure || closure.closureErrorParamIndex >= 0
        }
        if isThrowing
        {
            postAttribs = " throws" + postAttribs
        }
        
        let funcIndentation = swiftFunctionCreator.getFuncIndentation(bufferIndentationWidth: buffer.indentationWidth)
        
        let funcName = funcElements.name.hasSuffix("Async") ? String(funcElements.name.dropLast(5)) : funcElements.name
        var result = "\n\(funcIndentation)\(funcElements.attribs) \(funcName)Sync("
        for i in 0..<funcElements.params.count
        {
            let param = funcElements.params[i]
            if !swiftFunctionCreator.isSwiftEscapingClosure(type: param.type)
            {
                if i > 0
                {
                    result += ", "
                }
                result += param.body
            }
        }
        guard let firstLineIndentation = try? swiftFunctionCreator.getFuncFirstLineIndentation(funcBody: funcElements.body) else {
            completionHandler(DefaultError)
            return
        }
        guard let newBody = try? swiftFunctionCreator.createNewFuncBodySwift(firstLineIndentation: firstLineIndentation, funcName: funcElements.name, params: funcElements.params, returnType: returnType, isThrowing: isThrowing) else {
            completionHandler(DefaultError)
            return
        }
        result += ")\(postAttribs){\n\(newBody)\n\(funcIndentation)}"
        
        if buffer.lines.count == funcElements.endLineIndex-1
        {
            buffer.lines.add("")
        }
        buffer.lines.insert(result, at: funcElements.endLineIndex+1)
        completionHandler(nil)
    }
}
