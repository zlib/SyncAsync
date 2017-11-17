//
//  SwiftFunctionCreatorTests.swift
//  SyncAsyncTests
//
//  Created by Михаил Мотыженков on 17.11.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import XCTest

class SwiftFunctionCreatorTests: XCTestCase {
    
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
