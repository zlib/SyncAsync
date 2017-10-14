//
//  SwiftParamParser.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 15.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

class SwiftParamParser
{
    static func getParam(body: String) throws -> SwiftParam
    {
        let trimmedBody = body.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var name: String?
        var type: SwiftType

        if let colonIndex = (trimmedBody.index { (char) -> Bool in
            char == ":"
        })
        {
            name = String(trimmedBody[trimmedBody.startIndex..<colonIndex])
            type = try SwiftTypeParser.getType(fromString: String(trimmedBody[trimmedBody.index(after: colonIndex)..<trimmedBody.endIndex].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))
        }
        else
        {
            name = nil
            type = try SwiftTypeParser.getType(fromString: trimmedBody)
        }
        return SwiftParam(body: trimmedBody, name: name, type: type)
    }
    
    static func getParamsStrings(line: Substring) throws -> [String]
    {
        var depth = 0
        var firstIndex = line.startIndex
        var lastIndex = firstIndex
        var result = [String]()
        
        for i in 0..<line.count
        {
            lastIndex = line.index(line.startIndex, offsetBy: i)
            let char = line.characters[lastIndex]
            
            switch char {
            case "(": depth += 1
            case ")": depth -= 1
            case ",":
                if depth == 0
                {
                    result.append(String(line[firstIndex..<lastIndex].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))
                    if i < line.count
                    {
                        firstIndex = line.index(line.startIndex, offsetBy: i+1)
                    }
                }
            default: break
            }
        }
        if depth != 0
        {
            throw DefaultError
        }
        if line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        {
            result.append(String(line[firstIndex...lastIndex].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))
        }
        
        return result
    }
}
