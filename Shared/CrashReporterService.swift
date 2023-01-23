import Foundation
import DashTypes
import CoreSession
import DashlaneReportKit
import Sentry
import Combine
import SwiftUI
import SwiftTreats

private extension Application {
    static var environment: Environment {
        if self.version().starts(with: "70.") {
            return .qa
        } else if self.version().starts(with: "80.") {
            return .internal
        } else {
            return .production
        }
    }
}

private enum Environment: String {
    case production
    case qa
    case `internal`
}

class CrashReporterService: NSObject {
    @Published
    private var events: [Sentry.Event] = []
    
    init(target: BuildTarget) {
        super.init()

                guard BuildEnvironment.current != .debug else {
            return
        }
        
        let key: String
        switch target {
        case .app, .tachyon, .safari:
            key = ApplicationSecrets.Sentry.passwordManagerKey
        case .authenticator:
            key = ApplicationSecrets.Sentry.authenticatorKey
        }
        
        startSentry(key: key)
    }

    private func startSentry(key: String) {
        SentrySDK.start { [weak self] options in
            options.dsn = key

            options.enableSwizzling = false
            options.enableNetworkTracking = false
            options.enableNetworkBreadcrumbs = false
            #if os(iOS)
            options.enableUIViewControllerTracking = false
            options.enableUserInteractionTracing = false
            #endif
            options.enableAutoBreadcrumbTracking = false
            options.enableAutoPerformanceTracking = false
            options.enableOutOfMemoryTracking = false 

            options.environment = Application.environment.rawValue
            options.beforeSend = { [weak self] event in
                self?.events.append(event)
                return event
            }
        }
    }
    
        public func associate(to login: Login?) {
        SentrySDK.configureScope { scope in
            scope.setUser(.init(login: login))
        }
    }
}

fileprivate extension Sentry.User {
    convenience init?(login: Login?) {
        guard let login = login else {
            return nil
        }
        self.init()
        
        ipAddress = ""
        if login.isTest || Application.environment == .internal {
            email = login.email
        } else if let hashedEmail = login.email.lowercased().sha512() {
            userId = hashedEmail
        } else {
            return nil
        }
    }
}
