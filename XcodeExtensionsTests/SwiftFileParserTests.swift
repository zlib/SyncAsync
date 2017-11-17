//
//  SwiftFileParserTests.swift
//  XcodeExtensionsTests
//
//  Created by Михаил Мотыженков on 07.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import XCTest
import SyncAsync

class SwiftFileParserTests: XCTestCase {
    
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
        let parser = SwiftFileParser(buffer: code)
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
        XCTAssertEqual(res.params[0].type.body, "Int")
        XCTAssertEqual(res.params[1].body, "completionBlock: @escaping (result: Int, error: Error?) -> Void")
        XCTAssertEqual(res.params[1].name, "completionBlock")
        XCTAssertEqual(res.params[1].type.body, "@escaping (result: Int, error: Error?) -> Void")
        let body = """
        {
                guard let range = lines[startLine].range(of: "func") else {
                    throw SyncAsyncError
                }
                
                return (attribs: "", name: "", params: "", body: "", endLine: startLine)
            }
        """
        XCTAssertEqual(res.body, body)
        XCTAssertEqual(res.endLineIndex, 18)
        XCTAssertEqual(res.postAttribs, " throws -> Void ")
    }
    
    func testFuncElementsEndLineIndex() {
        let string = """
        func createFavorite(favorite: QWFavorite,
                            completion completionBlock: @escaping ((QWFavorite) -> ()),
                            error errorBlock: @escaping ((NSError) -> ())){
            self.favoritesService.createFavorite(with: favorite, completion: { [weak self] (remoteFavorite) in
                guard let strongSelf = self else { return }
                
                strongSelf.favoriteRepository.save(favorite, completionBlock: {
                    completionBlock(remoteFavorite)
                })
            }, error: { (err) in
                errorBlock(err as NSError)
            })
        }
        """
        
        let parser = SwiftFileParser(buffer: string)
        guard let result = try? parser.getFuncElements(startLineIndex: 0) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(result.endLineIndex, 12)
    }
}
