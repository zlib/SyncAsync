//
//  SwiftTypeDefaultValueCreator.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 18.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

extension SwiftType
{
    func defaultValue() throws -> String
    {
        if genericType != nil || body.hasPrefix("[") || isCustom
        {
            return body.replacingOccurrences(of: "?", with: "").replacingOccurrences(of: "!", with: "") + "()"
        }
        if body == "String"
        {
            return ""
        }
        if body.hasSuffix("?")
        {
            return "nil"
        }
        if self is SwiftTuple
        {
            guard let tuple = self as? SwiftTuple else {
                throw SwiftTypeDefaultValueError
            }
            var result = "("
            for i in 0..<tuple.params.count
            {
                if i > 0
                {
                    result += ", "
                }
                result += try tuple.params[i].type.defaultValue()
            }
            result += ")"
            return result
        }
        for number in numberTypes
        {
            if number == body
            {
                return "0"
            }
        }
        return "nil"
    }
}
