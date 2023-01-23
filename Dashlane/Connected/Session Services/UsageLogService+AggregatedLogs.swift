import Foundation
import CorePersonalData
import DashlaneReportKit

extension UsageLogService {
    typealias ServerKey = AggregatedLogService.ServerKey
    private static let valueForUserActions = "1" 

    private static let trackedPersonalDataInfoTypes: [UsageLogCode11PersonalData.TypeType] = [
        .address,
        .company,
        .email,
        .identity,
        .phone,
        .website
    ]

    private static let trackedPersonalDataPaymentTypes: [UsageLogCode11PersonalData.TypeType] = [
        .bankStatement,
        .paymentMeanCreditcard
    ]

    func aggregateIfNeeded(_ code: LogCodeProtocol) {
        guard let code = getServerKey(for: code) else { return }
        userActionsAggregatedLogs[code] = Self.valueForUserActions
    }

    private func getServerKey(for code: LogCodeProtocol) -> ServerKey? {
        switch code {
        case let log as UsageLogCode11PersonalData where log.action == .add && Self.trackedPersonalDataPaymentTypes.contains(log.type):
            return ServerKey.addedPayments
        case let log as UsageLogCode11PersonalData where log.action == .add && Self.trackedPersonalDataInfoTypes.contains(log.type):
            return ServerKey.addedInfo
        case let log as UsageLogCode11PersonalData where log.action == .add && log.type == .note:
            return ServerKey.storedNote
        case let log as UsageLogCode34UserNavigation where log.viewName == "KWPasswordGeneratorViewController":
            return ServerKey.viewedPasswordGenerator
        case let log as UsageLogCode35UserActionsMobile where log.action == "usePinCodeOn":
            return ServerKey.usePinCode
        case let log as UsageLogCode35UserActionsMobile where log.action == "useTouchIDOn":
            return ServerKey.useTouchID
        case let log as UsageLogCode35UserActionsMobile where log.action == "useFaceIDOn":
            return ServerKey.useFaceID
        case let log as UsageLogCode113SharingBackend where log.action == "inviteItemGroupMembers":
            return ServerKey.sharedPassword
        case let log as UsageLogCode94NewD2DM2DS2D where log.action == .see && log.screen == .step2:
            return ServerKey.m2dOnboardingStart
        case let log as UsageLogCode94NewD2DM2DS2D where log.action == .see && log.screen == .step3:
            return ServerKey.m2dOnboardingFinish
        case let log as UsageLogCode75GeneralActions where log.action == "copy" && log.type == "passwordGenerator":
            return ServerKey.copiedPasswordGenerator
        case is UsageLogCode7GeneratedPassword:
            return ServerKey.generatedPassword
        default:
            return nil
        }
    }

}
