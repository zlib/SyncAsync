//
//  XcodeExtensionsTests.swift
//  XcodeExtensionsTests
//
//  Created by Михаил Мотыженков on 07.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import XCTest
import SyncAsync

class XcodeExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFuncElements() {
        let code = """
        import Foundation

        class ClassParser {
        
            private var lines: [Substring]
            private var buffer: String
            
            init(buffer: String) {
                self.buffer = buffer
                self.lines = buffer.split(separator: " ")
            }
                
            func getFuncElements(startLine: Int, completionBlock: @escaping (result: Int, error: Error?) -> Void) throws -> Void {
                guard let range = lines[startLine].range(of: "func") else {
                    throw SyncAsyncError
                }
                
                return (attribs: "", name: "", params: "", body: "", endLine: startLine)
            }
        }
        """
        let parser = SwiftParser(buffer: code)
        let result = try? parser.getFuncElements(startLineIndex: 12)
        guard let res = result else {
            XCTFail()
            return
        }
        XCTAssertEqual(res.name, "getFuncElements")
        XCTAssertEqual(res.attribs, "func")
        XCTAssertEqual(res.params.count, 2)
        XCTAssertEqual(res.params[0].body, "startLine: Int")
        XCTAssertEqual(res.params[0].name, "startLine")
        XCTAssertEqual(res.params[0].type, "Int")
        XCTAssertEqual(res.params[1].body, "completionBlock: @escaping (result: Int, error: Error?) -> Void")
        XCTAssertEqual(res.params[1].name, "completionBlock")
        XCTAssertEqual(res.params[1].type, "@escaping (result: Int, error: Error?) -> Void")
        let body = """
        {
                guard let range = lines[startLine].range(of: "func") else {
                    throw SyncAsyncError
                }
                
                return (attribs: "", name: "", params: "", body: "", endLine: startLine)
            }
        """
        XCTAssertEqual(res.body, body)
        XCTAssertEqual(res.endLineIndex, code.count-3)
        XCTAssertEqual(res.postAttribs, " throws -> Void ")
    }
}
