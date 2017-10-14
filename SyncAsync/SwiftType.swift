//
//  SwiftType.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 14.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

class SwiftType: Equatable
{    
    let body: String
    let isCustom: Bool
    let genericType: SwiftType?
    
    init(body: String, isCustom: Bool, genericType: SwiftType?)
    {
        self.body = body
        self.isCustom = isCustom
        self.genericType = genericType
    }
    
    static func Void() -> SwiftType
    {
        return SwiftType(body: "Void", isCustom: false, genericType: nil)
    }
    
    static func == (lhs: SwiftType, rhs: SwiftType) -> Bool
    {
        return lhs.body == rhs.body && lhs.isCustom == rhs.isCustom && lhs.genericType == rhs.genericType
    }
}

class SwiftTuple: SwiftType
{
    let params: [SwiftParam]
    
    init(body: String, isCustom: Bool, params: [SwiftParam])
    {
        self.params = params
        super.init(body: body, isCustom: isCustom, genericType: nil)
    }
    
    static func == (lhs: SwiftTuple, rhs: SwiftType) -> Bool
    {
        guard let rhsTuple = rhs as? SwiftTuple else {
            return false
        }
        return lhs.body == rhsTuple.body && lhs.isCustom == rhsTuple.isCustom && lhs.genericType == rhsTuple.genericType && lhs.params == rhsTuple.params
    }
}

class SwiftClosure: SwiftTuple
{
    let returnType: SwiftType
    let attributes: [String]
    let isEscaping: Bool
    
    init(body: String, isCustom: Bool, params: [SwiftParam], returnType: SwiftType, attributes: [String], isEscaping: Bool)
    {
        self.returnType = returnType
        self.attributes = attributes
        self.isEscaping = isEscaping
        super.init(body: body, isCustom: isCustom, params: params)
    }
    
    convenience init(tuple: SwiftTuple, returnType: SwiftType, attributes: [String], isEscaping: Bool)
    {
        self.init(body: tuple.body, isCustom: tuple.isCustom, params: tuple.params, returnType: returnType, attributes: attributes, isEscaping: isEscaping)
    }
    
    static func == (lhs: SwiftClosure, rhs: SwiftType) -> Bool
    {
        guard let rhsClosure = rhs as? SwiftClosure else {
            return false
        }
        return lhs.body == rhsClosure.body && lhs.isCustom == rhsClosure.isCustom && lhs.genericType == rhsClosure.genericType && lhs.params == rhsClosure.params && lhs.returnType == rhsClosure.returnType && lhs.attributes == rhsClosure.attributes && lhs.isEscaping == rhsClosure.isEscaping
    }
}


