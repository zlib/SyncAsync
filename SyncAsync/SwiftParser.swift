//
//  SwiftParser.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 07.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

struct SwiftParser
{    
    private let lines: [Substring]
    private let buffer: String
    
    init(buffer: String)
    {
        self.buffer = buffer
        self.lines = buffer.split(separator: "\n", omittingEmptySubsequences: false)
    }
    
    func getFuncElements(startLineIndex: Int) throws -> (attribs: String, name: String, params: [SwiftFuncParam], postAttribs: String, body: String, endLineIndex: Int)
    {
        let startLine = lines[startLineIndex]
        guard let index = startLine.index(of: "(") else {
            throw SyncAsyncError
        }
        let attribsAndNameSubstring = startLine[..<index]
        guard let nameStartIndex = try? getNameStartIndex(line: attribsAndNameSubstring) else {
            throw SyncAsyncError
        }
        let name = String(attribsAndNameSubstring[nameStartIndex..<attribsAndNameSubstring.endIndex])
        let attribs = String(attribsAndNameSubstring[attribsAndNameSubstring.startIndex..<nameStartIndex].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        
        guard let paramsResult = try? buffer.getInner(startIndex: index.encodedOffset, openChar: "(", closeChar: ")") else {
            throw SyncAsyncError
        }
        guard let paramsStrings = try? SwiftFuncParam.getParamsStrings(line: paramsResult.substring) else {
            throw SyncAsyncError
        }
        let params = try! paramsStrings.map { (string) -> SwiftFuncParam in
            guard let result = try? SwiftFuncParam(body: string) else {
                throw SyncAsyncError
            }
            return result
        }
        
        guard let bodyResult = try? buffer.getInnerWithOpenCloseCharacters(startIndex: paramsResult.upperIndex.encodedOffset + 1, openChar: "{", closeChar: "}") else {
            throw SyncAsyncError
        }
        let newLines = bodyResult.substring.filter { (char) -> Bool in
            char == "\n"
        }
        let postAttribsStartIndex = buffer.index(after: paramsResult.upperIndex)
        let postAttribs = buffer[postAttribsStartIndex..<bodyResult.lowerIndex]
        
        return (attribs: attribs, name: name, params: params, postAttribs: String(postAttribs), body: String(bodyResult.substring), endLineIndex: startLineIndex + newLines.count)
    }
    
    static func getFuncFirstLineIndentation(funcBody: String) throws -> String
    {
        var result = ""
        var found = false
        for i in 0..<funcBody.count
        {
            let index = funcBody.characters.index(funcBody.startIndex, offsetBy: i)
            let char = funcBody.characters[index]
            if char == "\n"
            {
                found = true
            }
            else if found
            {
                if CharacterSet.whitespacesAndNewlines.contains(char.unicodeScalars.first!)
                {
                    result += " "
                }
                else
                {
                    return result
                }
            }
        }
        throw SyncAsyncError
    }
    
    private func getNameStartIndex(line: Substring) throws -> String.Index
    {
        for i in (0..<line.count).reversed()
        {
            let index = line.index(line.startIndex, offsetBy: i)
            let char = line.characters[index]
            if CharacterSet.whitespacesAndNewlines.contains(char.unicodeScalars.first!)
            {
                return line.index(line.startIndex, offsetBy: i+1)
            }
        }
        throw SyncAsyncError
    }
}
