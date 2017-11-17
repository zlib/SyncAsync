//
//  SwiftTypeParser.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 14.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

let numberTypes: Set<String> = ["Float", "Double", "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64"]
let knownStartSimpleTypes: Set<String> = ["AnyObject", "String", "Error"]
let otherSimpleTypes: Set<String> = ["Bool", "Any", "Void"]
let knownGenericTypes: Set<String> = ["Array", "Set", "Dictionary"]

class SwiftTypeParser
{
    static var simpleTypes: Set<String> = {
        return numberTypes.union(otherSimpleTypes)
    }()
    
    static func getType(fromString body: String) throws -> SwiftType
    {
        guard let indexOfGenericOpenBracket = body.index(of: "<") else {
            return try getType(fromString: body, genericType: nil)
        }
        return try getGenericType(fromString: body, indexOfGenericOpenBracket: indexOfGenericOpenBracket)
    }
    
    static func getGenericType(fromString body: String, indexOfGenericOpenBracket: String.Index) throws -> SwiftType
    {
        let genericTypeBody = try body.getInner(startIndex: indexOfGenericOpenBracket.encodedOffset, openChar: "<", closeChar: ">")
        let genericType = try getType(fromString: String(genericTypeBody.substring))
        
        let baseType = String(body[body.startIndex..<indexOfGenericOpenBracket])
        
        for string in knownGenericTypes
        {
            if baseType == string
            {
                return SwiftType(body: baseType, isCustom: false, genericType: genericType)
            }
        }
        return try getType(fromString: baseType, genericType: genericType)
    }
    
    static func getType(fromString body: String, genericType: SwiftType?) throws -> SwiftType
    {
        for string in simpleTypes
        {
            if body == string
            {
                return SwiftType(body: body, isCustom: false, genericType: genericType)
            }
        }
        for string in knownStartSimpleTypes
        {
            if body.hasPrefix(string)
            {
                return SwiftType(body: body, isCustom: false, genericType: genericType)
            }
        }
        if body.hasPrefix("@") || body.contains("->")
        {
            return try getClosure(fromString:body)
        }
        for string in ["Error", "Fail", "Success", "Block", "Closure"]
        {
            if body.contains(string)
            {
                if genericType != nil
                {
                    throw DefaultError
                }
                return SwiftClosure(body: body, isCustom: true, params: [SwiftParam](), returnType: SwiftType.Void(), attributes: [String](), isEscaping: true)
            }
        }
        if body == "()"
        {
            return SwiftType.Void()
        }
        if body.hasPrefix("(")
        {
            return try getTuple(fromString: body)
        }
        
        return SwiftType(body: body, isCustom: true, genericType: genericType)
    }
    
    static func getTuple(fromString body: String) throws -> SwiftTuple
    {
        let paramsBody = try body.getInner(startIndex: 0, openChar: "(", closeChar: ")")
        let paramsStrings = try SwiftParamParser.getParamsStrings(line: paramsBody.substring)
        let params = try paramsStrings.map { (paramBody) in
            return try SwiftParamParser.getParam(body: paramBody)
        }
        return SwiftTuple(body: body, isCustom: false, params: params)
    }
    
    fileprivate static func deleteExcessBrackets(body: String) throws -> String
    {
        guard let indexOfFirstClosingBracket = body.index(of: ")") else {
            return body
        }
        var countOfExcessOpenBrackets = -1
        for char in body[body.startIndex..<indexOfFirstClosingBracket]
        {
            if char == "("
            {
                countOfExcessOpenBrackets += 1
            }
        }
        var newBody = body
        var count = newBody.count
        var i = 0
        var charsToDelete = countOfExcessOpenBrackets
        while i < count && charsToDelete > 0
        {
            let index = newBody.index(newBody.startIndex, offsetBy: i)
            let char = body[index]
            if char == "("
            {
                newBody.remove(at: index)
                count -= 1
                charsToDelete -= 1
            }
            else
            {
                i += 1
            }
        }
        i = newBody.count-1
        charsToDelete = countOfExcessOpenBrackets
        while i >= 0 && charsToDelete > 0
        {
            let index = newBody.index(newBody.startIndex, offsetBy: i)
            let char = body[index]
            if char == ")"
            {
                newBody.remove(at: index)
                charsToDelete -= 1
            }
            else
            {
                i -= 1
            }
        }
        return newBody
    }
    
    static func getClosure(fromString body: String) throws -> SwiftClosure
    {
        var attributes = [String]()
        var isEscaping = false
        
        let newBody = try deleteExcessBrackets(body: body)
        
        guard let paramsBody = try? newBody.getInner(startIndex: 0, openChar: "(", closeChar: ")") else {
            let result = getAttributes(fromString: newBody)
            return SwiftClosure(body: newBody, isCustom: true, params: [SwiftParam](), returnType: SwiftType.Void(), attributes: Array(result.attributes.dropLast()), isEscaping: result.isEscaping)
        }
        
        if paramsBody.lowerIndex.encodedOffset > 0
        {
            let attributesBody = newBody[newBody.startIndex..<paramsBody.lowerIndex]
            let result = getAttributes(fromString: String(attributesBody))
            attributes = result.attributes
            isEscaping = result.isEscaping
        }
        
        let paramsStrings = try SwiftParamParser.getParamsStrings(line: paramsBody.substring)
        let params = try paramsStrings.map { (paramBody) in
            return try SwiftParamParser.getParam(body: paramBody)
        }
        
        let endPart = String(newBody[newBody.index(after: paramsBody.upperIndex)..<newBody.endIndex])
        let returnSymbol = "->"
        guard let range = endPart.range(of: returnSymbol) else {
            throw DefaultError
        }
        let returnTypeBody = endPart[range.upperBound..<endPart.endIndex].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let returnType = try SwiftTypeParser.getType(fromString: String(returnTypeBody))
        
        return SwiftClosure(body: newBody, isCustom: false, params: params, returnType: returnType, attributes: attributes, isEscaping: isEscaping)
    }
    
    private static func getAttributes(fromString body: String) -> (attributes: [String], isEscaping: Bool)
    {
        var attributes = [String]()
        var isEscaping = false
        body.split(separator: " ").forEach({ (attribute) in
            if attribute == "@escaping"
            {
                isEscaping = true
            }
            attributes.append(String(attribute))
        })
        return (attributes: attributes, isEscaping: isEscaping)
    }
}
