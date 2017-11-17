//
//  StringExtensionTests.swift
//  XcodeExtensionsTests
//
//  Created by Михаил Мотыженков on 07.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import XCTest

class StringExtensionTests: XCTestCase {

    func testGetInnerBrackets() {
        let string = """
        func a(123) {
            asdf ;as; l
            a;sldkf;alsdf
        }
        """
        
        guard let result = try? string.getInner(startIndex: 0, openChar: "(", closeChar: ")") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(result.substring, "123")
    }
    
    func testGetInnerCurlyBrackets() {
        let string = """
        func a(123) {
            asdf ;as; l
            a;sldkf;alsdf
        }
        """
        let expectedResult: Substring = """
        
            asdf ;as; l
            a;sldkf;alsdf

        """
        
        guard let result = try? string.getInner(startIndex: 0, openChar: "{", closeChar: "}") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(result.substring, expectedResult)
        XCTAssertEqual(result.lowerIndex.encodedOffset, 12)
        XCTAssertEqual(result.upperIndex.encodedOffset, string.count-1)
    }
    
    func testGetInnerCurlyBracketsWith2InnerBlocks() {
        let string = """
        func a(123) {
            asdf ;as; l
            {a asdfaf {
            asdlf asdf }
            aksd;aldfjk } asdf
            a;sldkf;alsdf
        }
        """
        let expectedResult: Substring = """
        
            asdf ;as; l
            {a asdfaf {
            asdlf asdf }
            aksd;aldfjk } asdf
            a;sldkf;alsdf
        
        """
        
        guard let result = try? string.getInner(startIndex: 0, openChar: "{", closeChar: "}") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(result.substring, expectedResult)
    }

}
