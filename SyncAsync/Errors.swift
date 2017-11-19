//
//  Errors.swift
//  SyncAsync
//
//  Created by Михаил Мотыженков on 14.10.2017.
//  Copyright © 2017 Михаил Мотыженков. All rights reserved.
//

import Foundation

let DefaultError = NSError(domain: "SyncAsync", code: -1, userInfo: nil)
let ObjcError = NSError(domain: "SyncAsync.ObjcIsNotSupported", code: -2, userInfo: nil)
let ClosureError = NSError(domain: "SyncAsync.Closure", code: 3, userInfo: nil)
let SwiftTypeDefaultValueError = NSError(domain: "SyncAsync.Type.Default", code: -4, userInfo: nil)
let StringExtensionError = NSError(domain: "StringsExtensions", code: -100, userInfo: nil)
