import Foundation
import DashlaneReportKit
import CorePersonalData
import Combine
import AuthenticationServices
import DashlaneAppKit
import LoginKit
import CoreSettings
import CorePremium
import DashTypes

class AggregatedLogService {

    enum ServerKey: String {
        case copiedPasswordGenerator
        case m2dOnboardingFinish
        case m2dOnboardingStart
        case sharedPassword
        case useFaceID
        case useTouchID
        case usePinCode
        case storedNote
        case generatedPassword
        case viewedPasswordGenerator
        case addedPayments
        case addedInfo
        case autofillIos = "autofill_ios"
        case resetMpWithBiometricsIos = "reset_mp_with_biometrics_ios"
        case reusedDistinct
        case reused
        case nbrPasswords
        case relativeStart
        case relativeEnd
        case content
        case teamsContent
    }

    private(set) var startDate: Date
    private let syncedSettings: SyncedSettingsService
    private let vaultItemsService: VaultItemsServiceProtocol
    private let teamSpaceService: TeamSpacesService
    private let usageLogService: UsageLogServiceProtocol
    private let identityDashboardService: IdentityDashboardServiceProtocol
    private let userSettings: UserSettings
    private let autofillService: AutofillService
    private let resetMasterPasswordService: ResetMasterPasswordService?

    private static let valueForUserActions = "1" 
    private var passwords: [String] = []
    private var autofillActivationStatus: AutofillActivationStatus = .unknown

    private var cancellables = Set<AnyCancellable>()
    private let logQueue: DispatchQueue

    init(vaultItemsService: VaultItemsServiceProtocol,
         syncedSettings: SyncedSettingsService,
         usageLogService: UsageLogServiceProtocol,
         teamSpaceService: TeamSpacesService,
         identityDashboardService: IdentityDashboardServiceProtocol,
         userSettings: UserSettings,
         resetMasterPasswordService: ResetMasterPasswordService?,
         autofillService: AutofillService) {
        self.startDate = Date()
        self.vaultItemsService = vaultItemsService
        self.syncedSettings = syncedSettings
        self.teamSpaceService = teamSpaceService
        self.usageLogService = usageLogService
        self.identityDashboardService = identityDashboardService
        self.userSettings = userSettings
        self.autofillService = autofillService
        self.resetMasterPasswordService = resetMasterPasswordService

        self.logQueue = .init(label: "Uploading logs queue", qos: .utility, attributes: .concurrent)

        autofillService.$activationStatus
            .assign(to: \.autofillActivationStatus, on: self)
            .store(in: &self.cancellables)

        NotificationCenter.default.publisher(for: UIApplication.applicationWillEnterForegroundNotification).sink { [weak self] _ in
            self?.resetSession()
        }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.applicationWillResignActiveNotification).sink { [weak self] _ in
            self?.uploadAggregatedLogs()
        }.store(in: &cancellables)

    }

    func unload() {
        uploadAggregatedLogs()
    }

    func uploadAggregatedLogs() {
        logQueue.async {
            self.computeAggregatedLogs { aggregatedLogs in
                guard let aggregatedLogs = aggregatedLogs else { return }
                self.usageLogService.uploadAggregatedLogs(aggregatedLogs)
            }
            self.resetSession()
        }
    }

    func computeAggregatedLogs(completion: @escaping ([String: Encodable]?) -> Void) {
        let contentValue: [ServerKey: String] = usageLogService.userActionsAggregatedLogs.merging(getCommonLogs()) {first, _ in first }
        var logs: [ServerKey: Encodable] = [:]
        let encodableContent = Dictionary(uniqueKeysWithValues: contentValue.map { key, value in (key.rawValue, value) })
        guard let data = try? JSONSerialization.data(withJSONObject: encodableContent),
            let content = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
        }
        guard let accountCreationDate = syncedSettings[\.accountCreationDatetime] else {
            completion(nil)
            return
        }
        logs[ServerKey.relativeStart] = startDate.timeIntervalSince(accountCreationDate)
        logs[ServerKey.relativeEnd] = Date().timeIntervalSince(accountCreationDate)
        logs[ServerKey.content] = content
        var dic = Dictionary(uniqueKeysWithValues: logs.map { key, value in (key.rawValue, value) })

                computeTeamsSpaceLogs { teamSpaceLogs in
            guard let teamSpaceLogs = teamSpaceLogs,
                let data = try? JSONSerialization.data(withJSONObject: teamSpaceLogs),
                let teamsContent = String(data: data, encoding: .utf8) else {
                    completion(dic)
                    return
            }
                        logs[ServerKey.teamsContent] = teamsContent
            dic = Dictionary(uniqueKeysWithValues: logs.map { key, value in (key.rawValue, value) })
            completion(dic)
        }
    }

                    private func getReusedPasswords() -> (reused: Int, reusedDistinct: Int) {
        assert(!Thread.isMainThread)
        self.passwords = vaultItemsService.credentials.map { $0.password }
        let dictionary = Dictionary(grouping: passwords) {$0}
        let reused = dictionary.reduce(0) { result, dic in
            let passwordCount = dic.value.count
            return result + (passwordCount > 1 ? passwordCount : 0)
        }
        let reusedDictinct = dictionary.filter { $0.value.count > 1 }.count
        return (reused, reusedDictinct)
    }

        private func getCommonLogs() -> [ServerKey: String] {
        var logs: [ServerKey: String] = [:]
        let resetMPActivated = resetMasterPasswordService?.isActive ?? true
        logs[ServerKey.resetMpWithBiometricsIos] = resetMPActivated ? "1" : "0"
        logs[ServerKey.autofillIos] = self.autofillActivationStatus == .enabled ? "1" : "0"
        let reusedPasswords = getReusedPasswords()
        logs[ServerKey.nbrPasswords] = "\(passwords.count)"
        logs[ServerKey.reused] = "\(reusedPasswords.reused)"
        logs[ServerKey.reusedDistinct] = "\(reusedPasswords.reusedDistinct)"
        return logs
    }

        func resetSession() {
        self.startDate = Date()
    }

    private func computeTeamsSpaceLogs(completion: @escaping ([String: Any]?) -> Void) {
        guard let spaceId = teamSpaceService.availableSpaces.compactMap({ space -> String? in
            guard case UserSpace.business = space else { return nil }
            return space.id
        }).first else {
            completion(nil)
            return
        }
        identityDashboardService.report(spaceId: spaceId) { report in
            let computedReport = [spaceId: report.computeUserActivityReportDictionary()]
            completion(computedReport)
        }
    }

}
