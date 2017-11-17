//
//  SwiftFunctionCreatorTests.swift
//  SyncAsyncTests
//
//  Created by Михаил Мотыженков on 17.11.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import XCTest

class SwiftFunctionCreatorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFirstLineIndentationWithFirstEmptyLine() {
        let string = "\n        \n        DispatchQueue.global(qos: .utility).async\n}"
        
        let creator = SwiftFunctionCreator()
        guard let result = try? creator.getFuncFirstLineIndentation(funcBody: string) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(result, "        ")
    }

}
