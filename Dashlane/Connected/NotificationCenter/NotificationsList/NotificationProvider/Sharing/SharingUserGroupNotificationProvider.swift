import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreSharing
import DashTypes
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import VaultKit

class SharingUserGroupNotificationProvider: NotificationProvider {
  private let sharingService: SharingServiceProtocol
  private let settingsStore: LocalSettingsStore
  private let session: Session

  @Published
  private var sharingNotificationInfo: Set<SharingNotificationInfo> = []

  init(
    session: Session,
    sharingService: SharingServiceProtocol,
    featureService: FeatureServiceProtocol,
    settingsStore: LocalSettingsStore
  ) {
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

        return
          notificationInfo
          .compactMap { [weak self] info -> AnyPublisher<DashlaneNotification, Never>? in
            self?.publisher(for: info)
          }
          .combineLatest()
      }
      .switchToLatest()
      .prepend([])
      .eraseToAnyPublisher()
  }

  private func publisher(for info: SharingNotificationInfo) -> AnyPublisher<
    DashlaneNotification, Never
  > {
    let settings = NotificationSettings(prefix: info.settingsPrefix, settings: settingsStore)

    return
      settings
      .settingsChangePublisher()
      .map { SharingRequestNotification(info: info, settings: settings) }
      .eraseToAnyPublisher()
  }
}

extension PendingUserGroup {
  fileprivate var notificationInfo: SharingNotificationInfo {
    .init(
      kind: .userGroup,
      referrer: referrer ?? "",
      id: id)
  }
}
