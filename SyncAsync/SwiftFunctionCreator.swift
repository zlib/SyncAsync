//
//  SwiftFunctionCreator.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 17.11.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

let StandardIndentation = "    "

class SwiftFunctionCreator {
    
    func getReturnType(closures: [SwiftParam]) -> SwiftType
    {
        var result = [SwiftParam]()
        for i in 0..<closures.count
        {
            let closure = closures[i]
            if closure.isErrorClosure
            {
                continue
            }
            let params = (closure.type as! SwiftClosure).params
            for j in 0..<params.count
            {
                if closure.closureErrorParamIndex == j
                {
                    continue
                }
                params[j].closureIndex = i
                result.append(params[j])
            }
        }
        if result.count == 0
        {
            return SwiftType.Void()
        }
        if result.count == 1
        {
            return result[0].type
        }
        return SwiftTuple(params: result)
    }
    
    func getFuncIndentation(bufferIndentationWidth: Int) -> String
    {
        var result = ""
        for _ in 0..<bufferIndentationWidth
        {
            result += " "
        }
        return result
    }
    
    func getFuncFirstLineIndentation(funcBody: String) throws -> String
    {
        var result = ""
        if funcBody.count < 2 {
            throw DefaultError
        }
        let body = funcBody[funcBody.index(after: funcBody.startIndex)...funcBody.index(before: funcBody.endIndex)]
        let lines = body.split(separator: "\n")
        for line in lines
        {
            result = ""
            for i in 0..<line.count
            {
                let index = line.index(line.startIndex, offsetBy: i)
                let char = line[index]
                if CharacterSet.whitespacesAndNewlines.contains(char.unicodeScalars.first!)
                {
                    result += String(char)
                }
                else
                {
                    return result
                }
            }
        }
        throw DefaultError
    }
    
    func isSwiftEscapingClosure(type: SwiftType) -> Bool
    {
        if let closure = type as? SwiftClosure {
            return closure.isEscaping
        }
        return false
    }
    
    func createNewFuncBodySwift(firstLineIndentation: String, funcName: String, params: [SwiftParam], returnType: SwiftType, isThrowing: Bool) throws -> String
    {
        var result = "\(firstLineIndentation)assert(!Thread.isMainThread)"
        result += "\n\(firstLineIndentation)let semaphore = DispatchSemaphore(value: 0)"
        let hasReturnValue = returnType.body != "Void"
        if hasReturnValue
        {
            result += "\n\(firstLineIndentation)var syncResult: \(returnType.body) = \(returnType.defaultValue())"
        }
        if isThrowing
        {
            result += "\n\(firstLineIndentation)var resultError: Error?"
        }
        result += "\n\(firstLineIndentation)\(funcName)("
        
        for i in 0..<params.count
        {
            let param = params[i]
            if i > 0
            {
                result += ", "
            }
            let name = param.externalName ?? param.name!
            if isSwiftEscapingClosure(type: param.type)
            {
                try createClosureBody(param: param, name: name, firstLineIndentation: firstLineIndentation, hasReturnValue: hasReturnValue, returnType: returnType, result: &result)
            }
            else
            {
                result += "\(name): \(param.name!)"
            }
        }
        result += ")"
        result += "\n\(firstLineIndentation)let _ = semaphore.wait(timeout: DispatchTime.distantFuture)"
        if isThrowing
        {
            result += "\n\(firstLineIndentation)if resultError != nil {"
            result += "\n\(firstLineIndentation)\(StandardIndentation)throw resultError!"
            result += "\n\(firstLineIndentation)}"
        }
        if hasReturnValue
        {
            result += "\n\(firstLineIndentation)return syncResult"
        }
        return result
    }
    
    func createClosureBody(param: SwiftParam, name: String, firstLineIndentation: String, hasReturnValue: Bool, returnType: SwiftType, result: inout String) throws
    {
        result += "\(name): {"
        let closure = param.type as! SwiftClosure
        var indexOfErrorParam = -1
        if param.isErrorClosure
        {
            result += " error in\n\(firstLineIndentation)\(StandardIndentation)resultError = error"
        }
        else if closure.params.count > 0
        {
            result += " ("
            for j in 0..<closure.params.count
            {
                let p = closure.params[j]
                if j > 0
                {
                    result += ", "
                }
                var name = p.name ?? "param\(j)"
                if p.name == "error" || p.type.body.hasPrefix("Error")
                {
                    indexOfErrorParam = j
                    name = "error"
                }
                result += name
            }
            result += ") in"
        }
        
        if indexOfErrorParam >= 0
        {
            let error = closure.params[indexOfErrorParam].name ?? "error"
            result += "\n\(firstLineIndentation)\(StandardIndentation)resultError = \(error)"
        }
        if hasReturnValue && !param.isErrorClosure
        {
            result += "\n\(firstLineIndentation)\(StandardIndentation)syncResult = "
            if closure.params.count > 0
            {
                if (closure.params.count == 1 || (closure.params.count == 2 && indexOfErrorParam >= 0)) && indexOfErrorParam != 0
                {
                    result += closure.params[0].name ?? "param0"
                }
                else
                {
                    guard let tuple = returnType as? SwiftTuple else {
                        throw DefaultError
                    }
                    result += "("
                    for j in 0..<closure.params.count
                    {
                        if indexOfErrorParam == j
                        {
                            continue
                        }
                        let p = closure.params[j]
                        if j > 0
                        {
                            result += ", "
                        }
                        if let tupleName = tuple.params[j].name, let paramName = p.name
                        {
                            result += "\(tupleName): \(paramName)"
                        }
                        else
                        {
                            result += "param\(j)"
                        }
                    }
                    result += ")"
                }
            }
        }
        result += "\n\(firstLineIndentation)\(StandardIndentation)semaphore.signal()"
        result += "\n\(firstLineIndentation)}"
    }
}
