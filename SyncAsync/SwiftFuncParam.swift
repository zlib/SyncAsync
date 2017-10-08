//
//  SwiftFuncParam.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 08.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

struct SwiftFuncParam
{
    let body: String
    let name: String
    let type: String
    let isClosure: Bool
    
    // Closure specific
    private(set) var params = [SwiftFuncParam]()
    private(set) var isEscaping = false
    
    init(body: String) throws
    {
        self.body = body.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.isClosure = self.body.contains("->")
        
        guard let colonIndex = (self.body.index { (char) -> Bool in
            char == ":"
        }) else {
            throw SyncAsyncError
        }
        self.name = String(self.body[self.body.startIndex..<colonIndex])
        self.type = String(self.body[self.body.index(after: colonIndex)..<self.body.endIndex].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        
        if self.isClosure
        {
            self.isEscaping = self.type.contains("@escaping")
            if self.isEscaping
            {
                if !self.type.contains("Void")
                {
                    throw SyncAsyncError
                }
            }
            
            guard let paramsResult = try? self.body.getInner(startIndex: colonIndex.encodedOffset, openChar: "(", closeChar: ")") else {
                throw SyncAsyncError
            }
            guard let paramsStrings = try? SwiftFuncParam.getParamsStrings(line: paramsResult.substring) else {
                throw SyncAsyncError
            }
            self.params = try! paramsStrings.map({ (string) -> SwiftFuncParam in
                guard let result = try? SwiftFuncParam(body: string) else {
                    throw SyncAsyncError
                }
                return result
            })
        }
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
            throw SyncAsyncError
        }
        if line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        {
            result.append(String(line[firstIndex...lastIndex].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))
        }
        
        return result
    }
}
