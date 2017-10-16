//
//  SwiftParam.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 08.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

class SwiftParam
{
    let body: String
    let name: String?
    let externalName: String?
    let type: SwiftType
    
    // Closure specific
    var isErrorClosure = false
    var closureErrorParamIndex = -1
    var closureIndex = -1
    
    init(body: String, name: String?, externalName: String?, type: SwiftType)
    {
        self.body = body
        self.name = name
        self.type = type
        self.externalName = externalName
    }
}

extension SwiftParam: Equatable
{
    static func == (lhs: SwiftParam, rhs: SwiftParam) -> Bool
    {
        return lhs.body == rhs.body && lhs.name == rhs.name && lhs.type == rhs.type
    }
}
