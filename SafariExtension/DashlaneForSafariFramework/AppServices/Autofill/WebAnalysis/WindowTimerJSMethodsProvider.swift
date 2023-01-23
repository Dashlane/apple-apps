import Foundation
import JavaScriptCore

@objc
class WindowTimerJSMethodsProvider: NSObject {
    var timeoutCounter = 0
    let queue: DispatchQueue
    var dispatchSources: [Int: DispatchSourceTimer] = [:]

    override init() {
        queue = DispatchQueue(label: "com.dashlane.windowtimers")
        super.init()
    }

    func extend(_ context: JSContext) {
        let setTimeout: @convention(block) (_ function: JSValue, _ timeout: JSValue) -> JSValue = {  [weak self] function, timeout in
            guard let self else {
                return JSValue(nullIn: context)
            }

            let originalArguments = JSContext.currentArguments() ?? []
            var arguments = [Any]()
            if originalArguments.count > 2 {
                arguments = Array(originalArguments[2..<originalArguments.count])
            }
            return self.intervalWithCallable(function, timeout: timeout, arguments: arguments, isInterval: false, context: context)
        }

        let setInterval: @convention(block) (_ function: JSValue, _ timeout: JSValue) -> JSValue = {  [weak self] function, timeout in
            guard let self else {
                return JSValue(nullIn: context)
            }

            let originalArguments = JSContext.currentArguments() ?? []
            return self.intervalWithCallable(function, timeout: timeout, arguments: originalArguments, isInterval: true, context: context)
        }

        let clearTimeout: @convention(block) (JSValue) -> Void = { [weak self] id in
            let id = Int(id.toUInt32())
            self?.dispatchSources[id]?.cancel()
            self?.dispatchSources.removeValue(forKey: id)
        }

        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
        context.setObject(clearTimeout, forKeyedSubscript: "clearTimeout" as NSString)
        context.setObject(setInterval, forKeyedSubscript: "setInterval"as NSString)
        context.setObject(clearTimeout, forKeyedSubscript: "clearInterval" as NSString)
    }

    private func intervalWithCallable(_ function: JSValue, timeout: JSValue, arguments: [Any], isInterval: Bool, context: JSContext) -> JSValue {
        let id = timeoutCounter
        timeoutCounter += 1
        let dispatchSource = DispatchSource.makeTimerSource(queue: queue)
        dispatchSource.setEventHandler {
            if !isInterval {
                dispatchSource.cancel()
            }

            if function.isString {
                function.context?.evaluateScript(function.toString())
            } else {
                function.call(withArguments: arguments)
            }
        }
        let dispatchInterval = Int(timeout.toUInt32())
        dispatchSource.schedule(deadline: .now() + .milliseconds(dispatchInterval),
                                repeating: isInterval ? .milliseconds(dispatchInterval) : .never,
                                leeway: .nanoseconds(10))
        dispatchSource.resume()
        dispatchSources[id] = dispatchSource

        return JSValue(object: NSNumber(value: id) , in: context)

    }
}
