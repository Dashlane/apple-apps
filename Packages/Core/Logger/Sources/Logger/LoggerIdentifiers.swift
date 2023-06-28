import Foundation
import DashTypes

public enum AppLoggerIdentifier: String, LoggerIdentifier, CaseIterable {
        case accountCreation

            case session

        case localSettings

            case lifecycle

        case remoteNotifications

        case sync

        case personalData

        case editing

        case iconLibrary

        case network

        case features

        case userTrackingLogs

        case identityDashboard

        case sharing

        case preferences

        case teamSpaces

        case abTesting

        case spotlight

        case views

        case dwmOnboarding

        case appTrackingTransparency

        case autofill

        case localCommunication

        case versionValidity

        case inAppPurchase

        case activityLogs

    public var stringValue: String { return self.rawValue.lowercased() }
}

public extension Logger {
        subscript(_ identifier: AppLoggerIdentifier) -> Logger {
        self.sublogger(for: identifier)
    }
}
