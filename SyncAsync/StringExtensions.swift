//
//  StringExtensions.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 07.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

fileprivate let firstOpenCharDefaultValue = -1

extension String
{
    func getInnerWithOpenCloseCharacters(startIndex: Int, openChar: Character, closeChar: Character) throws -> (substring: Substring, lowerIndex: String.Index, upperIndex: String.Index)
    {
        var depth = 0
        var firstOpenCharIndex = self.index(self.startIndex, offsetBy: 0)
        var foundOpenChar = false
        for i in startIndex..<self.count
        {
            let index = self.index(self.startIndex, offsetBy: i)
            let char = self[index]
            if char == openChar
            {
                depth += 1
                if !foundOpenChar
                {
                    firstOpenCharIndex = index
                }
                foundOpenChar = true
            }
            else if char == closeChar
            {
                if !foundOpenChar
                {
                    throw StringExtensionError
                }
                depth -= 1
                if depth == 0
                {
                    let endIndex = self.index(self.startIndex, offsetBy: i)
                    return (substring: self[firstOpenCharIndex...endIndex],
                           lowerIndex: firstOpenCharIndex,
                           upperIndex: endIndex)
                }
            }
        }
        throw StringExtensionError
    }
    
    func getInner(startIndex: Int, openChar: Character, closeChar: Character) throws -> (substring: Substring, lowerIndex: String.Index, upperIndex: String.Index)
    {
        guard let result = try? getInnerWithOpenCloseCharacters(startIndex:startIndex, openChar:openChar, closeChar:closeChar) else
        {
            throw StringExtensionError
        }
        return (substring: Substring(result.substring.dropFirst().dropLast()),
               lowerIndex: result.lowerIndex,
               upperIndex: result.upperIndex)
    }
}

