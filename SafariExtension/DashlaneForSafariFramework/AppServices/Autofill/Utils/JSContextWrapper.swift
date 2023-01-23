import Foundation
import JavaScriptCore
import DashTypes
import Logger

public final class JSContextWrapper {
    
    private static let virtualMachine = JSVirtualMachine()
    private let endpoint: Endpoint
    private let context: JSContext
    private let browser: Browser
    let windowTimerProvider = WindowTimerJSMethodsProvider()
    let xmlHTTPRequestProvider = XMLHTTPRequestJSMethodsProvider()


    public init(browser: Browser, messageDispatcher: AutofillMessageDispatcher, endpoint: Endpoint, logger: Logger) {
        self.endpoint = endpoint
        self.context = JSContext(virtualMachine: JSContextWrapper.virtualMachine)
        context.name = endpoint.stringValue
        context.exceptionHandler = { context, value in            
            guard let context = context, let value = value else { return }
            logger.error("exception in \(endpoint.stringValue): \(value)")
            context.exception = value
        }
        
        windowTimerProvider.extend(context)
        xmlHTTPRequestProvider.extend(context)
        
        self.browser = browser
        
        context.setObject(ExportedStorage(endpoint: endpoint, logger: logger),
                          forKeyedSubscript: "storage" as (NSCopying & NSObjectProtocol))
        context.setObject(browser,
                          forKeyedSubscript: "injectedBrowser" as (NSCopying & NSObjectProtocol))
        context.setObject(AutofillMessageDispatcherWrapper(messageDispatcher: messageDispatcher, logger: logger),
                          forKeyedSubscript: "communicationCenter" as (NSCopying & NSObjectProtocol))
    }
    
    public func load(path: String) {
        let bundle = Bundle(for: type(of: self))
        let scriptUrl = bundle.resourceURL!.appendingPathComponent(path)
        let scriptContent = try! String(contentsOf: scriptUrl)
        context.evaluateScript(scriptContent, withSourceURL: scriptUrl)
    }
    
    public func call(_ name: String, arguments: [Any] = []) {
                context.objectForKeyedSubscript(name)?
            .call(withArguments: arguments)
    }
}

private extension KibanaLogger.ExceptionLogRequest {
    
    static func request(from value: JSValue) -> KibanaLogger.ExceptionLogRequest {
        let line = value.objectForKeyedSubscript("line")?.toObject() as? Int
        let sourceURL = value.objectForKeyedSubscript("sourceURL")?.toObject() as? String
        let stack = value.objectForKeyedSubscript("stack")?.toObject() as? String
        
        return .init(action: "logOnline",
                     code: .error,
                     message: "\(value)",
                     stack: stack,
                     exceptiontype: "NO_TYPE",
                     line: line,
                     file: sourceURL,
                     legacy: false)
    }
}

