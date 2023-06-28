import Foundation
import DashlaneAppKit
import SwiftTreats
import Combine
import CoreFeature
import CorePremium
import CorePersonalData
import CoreSharing
import CoreSession
import CoreSettings
import VaultKit
import SwiftUI
import DashTypes
import DesignSystem

  class SharingUserGroupNotificationProvider: NotificationProvider {
    private let sharingService: SharingServiceProtocol
    private let settingsStore: LocalSettingsStore
    private let session: Session

    @Published
    private var sharingNotificationInfo: Set<SharingNotificationInfo> = []

    init(session: Session,
         sharingService: SharingServiceProtocol,
         featureService: FeatureServiceProtocol,
         settingsStore: LocalSettingsStore) {
        self.sharingService = sharingService
        self.session = session
        self.settingsStore = settingsStore

        setupPublisher()
    }

    private func setupPublisher() {
        sharingService
            .pendingUserGroupsPublisher()
            .map {
                Set($0.map(\.notificationInfo))
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$sharingNotificationInfo)
    }

        public func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never> {
        $sharingNotificationInfo
            .map { notificationInfo -> AnyPublisher<[DashlaneNotification], Never> in
                guard !notificationInfo.isEmpty else {
                    return Just<[DashlaneNotification]>([]).eraseToAnyPublisher()
                }

                return notificationInfo
                    .compactMap { [weak self] info -> AnyPublisher<DashlaneNotification, Never>? in
                        self?.publisher(for: info)
                    }
                    .combineLatest()
            }
            .switchToLatest()
            .prepend([])
            .eraseToAnyPublisher()
    }

    private func publisher(for info: SharingNotificationInfo) -> AnyPublisher<DashlaneNotification, Never> {
        let settings = NotificationSettings(prefix: info.settingsPrefix, settings: settingsStore)

        return settings
            .settingsChangePublisher()
            .map { SharingRequestNotification(info: info, settings: settings) }
            .eraseToAnyPublisher()
    }
 }

 private extension PendingUserGroup {
    var notificationInfo: SharingNotificationInfo {
        .init(vaultItem: nil,
              referrer: referrer ?? "",
              id: id)
    }
 }

struct SharingNotificationInfo: Hashable {
    var settingsPrefix: String {
        "sharing-nrrequest-\(id.rawValue)"
    }

    let vaultItem: VaultItem?
    let referrer: String
    let id: Identifier

    static func == (lhs: SharingNotificationInfo, rhs: SharingNotificationInfo) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SharingRequestNotification: DashlaneNotification {
    let state: NotificationCenterService.Notification.State
    let icon = Image.ds.action.share.outlined
    let title: String = L10n.Localizable.actionItemSharingTitle
    let description: String
    let category: NotificationCategory = .sharing
    let notificationActionHandler: NotificationActionHandler
    let kind: NotificationCenterService.Notification
    let id: String
    let creationDate: Date

    init(state: NotificationCenterService.Notification.State,
         creationDate: Date,
         notificationActionHandler: NotificationActionHandler,
         vaultItem: VaultItem?,
         referrer: String,
         requestId: String,
         settingsPrefix: String) {
        self.creationDate = creationDate
        self.state = state
        self.notificationActionHandler = notificationActionHandler
        self.id = settingsPrefix
        self.kind = .dynamic(.sharing(requestId: requestId))
        switch vaultItem {
        case .some(let credential) where credential is Credential:
            self.description = L10n.Localizable.actionItemSharingDetail(referrer, credential.localizedTitle)
        case is SecureNote:
            self.description = L10n.Localizable.actionItemSharingDetailSecurenote(referrer)
        default:
            self.description = L10n.Localizable.actionItemSharingDetailGroup(referrer)
        }
    }

    init(info: SharingNotificationInfo,
         settings: NotificationSettings) {
        self.init(state: settings.fetchState(),
                  creationDate: settings.creationDate,
                  notificationActionHandler: settings,
                  vaultItem: info.vaultItem,
                  referrer: info.referrer,
                  requestId: info.id.rawValue,
                  settingsPrefix: info.settingsPrefix)
    }
}
