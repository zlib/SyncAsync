# What is it?

Let's assume you have a method like this:
```
func doSomething(param: Int, completionHandler: @escaping () -> Void) {
    DispatchQueue.global().async {
        print(param)
        completionHandler()
    }
}
```
And you want to have a synchronous version of that. Something like this:
```
func doSomethingSync(param: Int)
```

You can do it with this Xcode extension. 

# Is it useful?

Sometimes in order to make next request you need to wait for result of a previous one:
```
let result1 = doSomething1()
let result2 = doSomething2(param: result1)
let result3 = doSomething3(param: result2)
...
let resultN = doSomethingN(param: resultN-1)
```

Furthermore, if you call a sequence of functions with escaping closures your error handling can become a mess. If your completion handlers contain Error object this extension generates a throwable synchronous version. Thus you can handle your errors in a native swifty way:
```
DispatchQueue.global().async {
    do {
        try doSomething1()
        try doSomething2()
        try doSomething3()
    } catch {
        print(error)
    }
}
```

# Examples

## Example 1
Source function:
```
func doSomethingAsync(param: String, completion: @escaping () -> ()) {
    DispatchQueue.global().async {
        print(param)
        completion()
    }
}
```

Generated function:
```
func doSomethingSync(param: String) {
    assert(!Thread.isMainThread)
    let semaphore = DispatchSemaphore(value: 0)
    doSomething(param: param, completion: {
        semaphore.signal()
    })
    let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
}
```

## Example 2
Source function:
```
func doSomething(a: CustomType, b: CustomType, complete: @escaping (CustomType?, Error?) -> Void) {
    DispatchQueue.global().async {
        guard let result = try? someOperation(a, b) else {
            complete(nil, NSError(domain: "com.syncAsync.default", code: -1, userInfo: nil))
            return
        }
        complete(result, nil)
    }
}
```

Generated function:
```
func doSomethingSync(a: CustomType, b: CustomType) throws -> CustomType? {
    assert(!Thread.isMainThread)
    let semaphore = DispatchSemaphore(value: 0)
    var syncResult: CustomType? = CustomType()
    var resultError: Error?
    doSomething(a: a, b: b, complete: { (param0, error) in
        resultError = error
        syncResult = param0
        semaphore.signal()
    })
    let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    if resultError != nil {
        throw resultError!
    }
    return syncResult
}
```

## Example 3
Source function:
```
func doSomething(a: Int, b: Int, complete: @escaping (Int, Int) -> Void, fail: @escaping (Error) -> Void) {
    DispatchQueue.global().async {
        print(a)
        print(b)
        let result1 = a + b
        let result2 = a - b
        if result1 + result2 > 0 {
            complete(result1, result2)
        } else {
            fail(NSError(domain: "com.syncAsync.default", code: -1, userInfo: nil))
        }
    }
}
```

Generated function:
```
func doSomethingSync(a: Int, b: Int) throws -> (Int, Int) {
    assert(!Thread.isMainThread)
    let semaphore = DispatchSemaphore(value: 0)
    var syncResult: (Int, Int) = (0, 0)
    var resultError: Error?
    doSomething(a: a, b: b, complete: { (param0, param1) in
        syncResult = (param0, param1)
        semaphore.signal()
    }, fail: { (error) in
        resultError = error
        semaphore.signal()
    })
    let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    if resultError != nil {
        throw resultError!
    }
    return syncResult
}
```

# Installation

1. Download the app from here: https://drive.google.com/open?id=1iUXEjB-_EVaO0egxSLucl91g1_LYgo1g or build it from sources.
2. Copy the app to the Applications folder.
3. Go to the System Preferences and choose 'Extensions'. Turn on SyncAsync extension.

# Usage
Click on function with escaping closure and select Editor -> SyncAsync -> Make sync.

You can also assign a shortcut to automatically invoke the 'Make sync' command. Go to Xcode's preferences and choose 'Key Bindings' tab.

# WARNING!
Do NOT call those generated synchonous functions on the main thread!

# Author
Mikhail Motyzhenkov, m.motyzhenkov@gmail.com

# License
SyncAsync is available under the MIT license.