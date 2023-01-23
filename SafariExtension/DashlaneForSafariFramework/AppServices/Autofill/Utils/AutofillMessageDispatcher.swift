import Foundation
import DashTypes
import JavaScriptCore

public class AutofillMessageDispatcher {

    private let queue = DispatchQueue(label: "message_dispatcher", qos: .userInitiated)

    let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    private var listeners = [Endpoint: [(listener: AnyObject, call: (Communication) -> Void)]]()

    deinit {
        logger.debug("Remove all listeners")
        listeners.removeAll()
    }

    func addObserver(on endpoint: Endpoint, listener: AnyObject, call: @escaping (Communication) -> Void) {
        logger.debug("Add observer \(listener) for endpoint \(endpoint)")
        queue.async {
            self.listeners[endpoint, default: []].append((listener, call))
            self.logger.debug("Number of listeners for \(endpoint) -> \(self.listeners[endpoint]?.count ?? 0)")
        }
    }

    func removeObserver(for endpoint: Endpoint, listener: AnyObject) {
        logger.debug("Remove observer \(listener) for endpoint \(endpoint)")
        queue.async {
            self.listeners[endpoint]?.removeAll { (tuple) -> Bool in
                return tuple.listener === listener
            }
            self.logger.debug("Number of listeners for \(endpoint) -> \(self.listeners[endpoint]?.count ?? 0)")
        }
    }

    func post(_ communication: Communication) {
        guard communication.to != Endpoint.unspecified else {
            logger.error("cannot send message to unspecified destination")
            return
        }
        guard communication.isValid else {
            logger.error("invalid communication - please check: \(communication)")
            return
        }
        logger.debug("\(communication)")

        queue.async {
            self.listeners[communication.to]?.forEach { (tuple) in
                tuple.call(communication)
            }
        }
    }
}

@objc private protocol AutofillMessageDispatcherExport: JSExport {
    func post(_ from: String, _ to: String, _ subject: String, _ body: [String: Any] )
    func addObserver(_ endpoint: String, _ callback: JSValue) 
}

final class AutofillMessageDispatcherWrapper: NSObject, AutofillMessageDispatcherExport {

    private let messageDispatcher: AutofillMessageDispatcher
    private let logger: Logger

    private var registeredEndpoints = [Endpoint]()

    init(messageDispatcher: AutofillMessageDispatcher, logger: Logger) {
        self.messageDispatcher = messageDispatcher
        self.logger = logger

        super.init()
    }

    deinit {
        registeredEndpoints.forEach {
            messageDispatcher.removeObserver(for: $0, listener: self)
        }
    }

    func post(_ from: String, _ to: String, _ subject: String, _ body: [String: Any] ) {
        let communication = Communication(from: from, to: to, subject: subject, body: body)
        messageDispatcher.post(communication)
    }

    func addObserver(_ endpoint: String, _ callback: JSValue) {
        let endpointValue = Endpoint(stringValue: endpoint)
        registeredEndpoints.append(endpointValue)
        messageDispatcher.addObserver(on: endpointValue, listener: self) { communication in
            callback.call(withArguments: [communication.from, communication.to, communication.subject, communication.body])
        }
    }
}
