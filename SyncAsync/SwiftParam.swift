//
//  SwiftParam.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 08.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

struct SwiftParam
{
    let body: String
    let name: String?
    let type: SwiftType
    
    init(body: String, name: String?, type: SwiftType)
    {
        self.body = body
        self.name = name
        self.type = type
    }
}

extension SwiftParam: Equatable
{
    static func == (lhs: SwiftParam, rhs: SwiftParam) -> Bool
    {
        return lhs.body == rhs.body && lhs.name == rhs.name && lhs.type == rhs.type
    }
}
