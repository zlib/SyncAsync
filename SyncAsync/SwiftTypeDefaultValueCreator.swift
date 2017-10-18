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
    func defaultValue() -> String
    {
        if genericType != nil || body.hasPrefix("[") || isCustom
        {
            return body + "()"
        }
        if body == "String"
        {
            return ""
        }
        if body.hasSuffix("?")
        {
            return "nil"
        }
        for number in numberTypes
        {
            if number == body
            {
                return "0"
            }
        }
        return ""
    }
}
