//
//  SwiftTypeParserTests.swift
//  XcodeExtensionsTests
//
//  Created by Михаил Мотыженков on 14.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import XCTest

class SwiftTypeParserTests: XCTestCase {

    func testEscapingClosureWithNamedParams() {
        let closure = "@escaping (result: Int, error: Error?) -> Void"
        
        let result = try! SwiftTypeParser.getClosure(fromString: closure)
        
        XCTAssertEqual(result.isEscaping, true)
        XCTAssertEqual(result.attributes.count, 1)
        XCTAssertEqual(result.returnType, SwiftType.Void())
        XCTAssertEqual(result.body, closure)
        XCTAssertEqual(result.genericType, nil)
        XCTAssertEqual(result.isCustom, false)
        let params = [SwiftParam(body: "result: Int", name: "result", externalName: nil, type: SwiftType(body: "Int", isCustom: false, genericType: nil)),
                      SwiftParam(body: "error: Error?", name: "error", externalName: nil, type: SwiftType(body: "Error?", isCustom: false, genericType: nil))]
        XCTAssertEqual(result.params, params)
    }
    
    func testNonEscapingClosureWithTwoEscapingClosures() {
        let closure = "(result: Int, success: @escaping Success, error: @escaping ErrorBlock) -> Void"
        
        let result = try! SwiftTypeParser.getClosure(fromString: closure)
        
        XCTAssertEqual(result.isEscaping, false)
        XCTAssertEqual(result.attributes.count, 0)
        XCTAssertEqual(result.returnType, SwiftType.Void())
        XCTAssertEqual(result.body, closure)
        XCTAssertEqual(result.genericType, nil)
        XCTAssertEqual(result.isCustom, false)
        let params = [SwiftParam(body: "result: Int", name: "result", externalName: nil, type: SwiftType(body: "Int", isCustom: false, genericType: nil)),
                      SwiftParam(body: "success: @escaping Success", name: "success", externalName: nil, type: SwiftClosure(body: "@escaping Success", isCustom: true, params: [SwiftParam](), returnType: SwiftType.Void(), attributes: ["@escaping"], isEscaping: true) ),
                      SwiftParam(body: "error: @escaping ErrorBlock", name: "error", externalName: nil, type: SwiftClosure(body: "@escaping ErrorBlock", isCustom: true, params: [SwiftParam](), returnType: SwiftType.Void(), attributes: ["@escaping"], isEscaping: true) )]
        XCTAssertEqual(result.params, params)
    }
    
    func testEscapingClosureWithManyBrackets() {
        let string = "@escaping ((QWFavorite) -> ())"
        
        guard let result = try? SwiftTypeParser.getType(fromString: string) else {
            XCTFail()
            return
        }
        
        guard let closureType = result as? SwiftClosure else {
            XCTFail()
            return
        }

        XCTAssertEqual(closureType.body, "@escaping (QWFavorite) -> ()")
        XCTAssertEqual(closureType.genericType, nil)
        XCTAssertEqual(closureType.isCustom, false)
        XCTAssertEqual(closureType.attributes.count, 1)
        XCTAssertEqual(closureType.attributes[0], "@escaping")
        XCTAssertEqual(closureType.isEscaping, true)
        XCTAssertEqual(closureType.returnType, SwiftType.Void())
        XCTAssertEqual(closureType.params.count, 1)
        XCTAssertEqual(closureType.params[0].body, "QWFavorite")
    }

}
