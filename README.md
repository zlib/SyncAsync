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

You can do it easily with this Xcode extension. 

# Is it useful?

Sometimes in order to make next request you need to wait for result of a previous one:
```
let result1 = doSomething1()
let result2 = doSomething2(param: result1)
let result3 = doSomething3(param: result2)
...
let resultN = doSomethingN(param: resultN-1)
```

Furthermore if you write a sequence of functions with completion handlers your error handling can become a mess. If your completion handlers contain Error object this extension generates a throwable synchronous version. Thus you can handle your errors in a native swifty way:
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

# WARNING!
Do NOT call those generated synchonous functions on the main thread!

# Installation

1. Download the app from here: https://drive.google.com/open?id=12QoDEyQ35nZ9XIq7wwyJknA1g6SRs7w4 or build it from sources.
2. Copy the app to the Applications folder.
3. Go to the System Preferences and choose 'Extensions'. Turn on SyncAsync extension.

# Usage
Click on function with escaping closure and select Editor -> SyncAsync -> Make sync.
You can also assign a shortcut to automatically invoke the 'Make sync' command in Xcode preferences.