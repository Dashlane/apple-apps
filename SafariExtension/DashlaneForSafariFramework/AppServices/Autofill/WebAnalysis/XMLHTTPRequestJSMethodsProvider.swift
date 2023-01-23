import Foundation
import JavaScriptCore


@objc
protocol XMLHTTPRequestJSMethodsProviderProtocol: JSExport {
    var responseText: NSString? { get set }
    var onreadystatechange: JSValue? { get set }
    var readyState: NSNumber { get set }
    var onload: JSValue? { get set }
    var onerror: JSValue? { get set }
    var status: NSNumber? { get set }

    func open(_ httpMethod: NSString, _ url: NSString, _ async: NSNumber)
    func send(_ data: JSValue)
    func setRequestHeader(name: NSString, value: NSString)
    func getAllResponseHeaders() -> NSString
    func getResponseHeader(name: NSString) -> NSString?
    func setAllResponseHeaders(responseHeaders: [AnyHashable: Any])
}


@objc
class XMLHTTPRequestJSMethodsProvider: NSObject, XMLHTTPRequestJSMethodsProviderProtocol {
    dynamic var responseText: NSString?
    dynamic var onreadystatechange: JSValue?
    dynamic var readyState: NSNumber = 0.0
    dynamic var onload: JSValue?
    dynamic var onerror: JSValue?
    dynamic var status: NSNumber?

    private let urlSession = URLSession.shared
    private var httpMethod: String = "GET"
    private var url: URL?
    private var async: Bool = false
    private var requestHeaders: [String: String] = [:]
    private var responseHeaders: [String: String]?

            enum ReadyState: Int {
                case unsent = 0
                case opened
                case headers
                case loading
                case done
    }

    func extend(_ context: JSContext) {
        let make: @convention(block) () -> XMLHTTPRequestJSMethodsProvider = {
            return self
        }

        context.setObject(make, forKeyedSubscript: "XMLHttpRequest" as NSString)
        let value = context.objectForKeyedSubscript("XMLHttpRequest")

        value?.setObject(NSNumber(value: ReadyState.unsent.rawValue), forKeyedSubscript: "UNSENT" as NSString)
        value?.setObject(NSNumber(value: ReadyState.opened.rawValue), forKeyedSubscript: "OPENED" as NSString)
        value?.setObject(NSNumber(value: ReadyState.loading.rawValue), forKeyedSubscript: "LOADING" as NSString)
        value?.setObject(NSNumber(value: ReadyState.headers.rawValue), forKeyedSubscript: "HEADERS" as NSString)
        value?.setObject(NSNumber(value: ReadyState.done.rawValue), forKeyedSubscript: "DONE" as NSString)
    }

    func open(_ httpMethod: NSString, _ url: NSString, _ async: NSNumber) {
                self.httpMethod = httpMethod as String
        self.url = URL(string: url as String)
        self.async = async.boolValue
        self.readyState = NSNumber(value: ReadyState.unsent.rawValue)
    }

    func send(_ data: JSValue) {
        guard let url = url else {
            return
        }

        Task {
            var request = URLRequest(url: url)
            for (name, value) in requestHeaders {
                request.setValue(value, forHTTPHeaderField: name)
            }
            if let data = data.toString() {
                request.httpBody = data.data(using: .utf8)
            }
            request.httpMethod = httpMethod

            do {
                let (data, response) = try await urlSession.data(for: request)
                let httpResponse = response as! HTTPURLResponse
                readyState = NSNumber(value: ReadyState.done.rawValue)
                status = NSNumber(value: httpResponse.statusCode)
                responseText = String(data: data, encoding: .utf8).map {
                    NSString(string: $0)
                }
                responseHeaders = httpResponse.allHeaderFields as? [String: String]
                                   
                onreadystatechange?.call(withArguments: [])


            } catch {
                onreadystatechange?.call(withArguments: [])
                readyState = NSNumber(value: ReadyState.done.rawValue)
                onerror?.call(withArguments: [])
            }
        }
    }

    func setRequestHeader(name: NSString, value: NSString) {
        requestHeaders[name as String] = value as String
    }

    func getAllResponseHeaders() -> NSString {
        guard let responseHeaders else {
            return "" as NSString
        }
        return responseHeaders.reduce("", { partialResult, keyValue  in
            return partialResult + "\(keyValue.key):\(keyValue.value)\n"
        }) as NSString
    }

    func getResponseHeader(name: NSString) -> NSString? {
        return responseHeaders?[name as String].map { $0 as NSString }
    }

    func setAllResponseHeaders(responseHeaders: [AnyHashable: Any]) {
        guard let responseHeaders = responseHeaders as? [String: String] else {
            return
        }

        self.responseHeaders = responseHeaders
    }
}
