import Foundation
import DashTypes
import JavaScriptCore

public final class BackgroundService {

    private let queue = DispatchQueue(label: "com.dashlane.BackgroundService", qos: .userInitiated)

    private let messageDispatcher: AutofillMessageDispatcher
    private let logger: Logger
    private var context: JSContextWrapper!
    
    init(browser: Browser, messageDispatcher: AutofillMessageDispatcher, logger: Logger) {
        self.messageDispatcher = messageDispatcher
        self.logger = logger
        self.context = Self.setupContextSynchronously(in: queue, messageDispatcher: messageDispatcher, browser: browser, logger: logger)
    }

    private static func setupContextSynchronously(in queue: DispatchQueue,
                                                  messageDispatcher: AutofillMessageDispatcher,
                                                  browser: Browser,
                                                  logger: Logger) -> JSContextWrapper {
        var contextWrapper: JSContextWrapper!
        queue.sync {
            let context = JSContextWrapper(browser: browser,
                                           messageDispatcher: messageDispatcher,
                                           endpoint: .background,
                                           logger: logger)
            
                        context.load(path: "JsBundle/background.js")
            context.load(path: "JsBundle/safariBundle.js")
            context.load(path: "backgroundStartup.js")

            context.call("startup", arguments: [])

            contextWrapper = context
        }
        return contextWrapper
    }
}
