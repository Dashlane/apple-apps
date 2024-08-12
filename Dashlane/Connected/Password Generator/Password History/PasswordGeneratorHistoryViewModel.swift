import Combine
import CorePersonalData
import CoreSettings
import CoreUserTracking
import Foundation
import IconLibrary
import SwiftUI
import UIDelight
import VaultKit

class PasswordGeneratorHistoryViewModel: ObservableObject, SessionServicesInjecting {
  enum State: Equatable {
    case loading
    case empty
    case loaded(passwords: [DateGroup: [GeneratedPassword]])
  }

  @Published
  var state: State = .loading

  let pasteboardService: PasteboardService
  let iconService: VaultKit.IconServiceProtocol
  let activityReporter: ActivityReporterProtocol

  init(
    database: ApplicationDatabase,
    userSettings: UserSettings,
    activityReporter: ActivityReporterProtocol,
    iconService: IconServiceProtocol
  ) {
    pasteboardService = PasteboardService(userSettings: userSettings)
    self.iconService = iconService
    self.activityReporter = activityReporter
    database
      .itemsPublisher(for: GeneratedPassword.self)
      .map { Array($0) }
      .receive(on: DispatchQueue.global(qos: .userInitiated))
      .map { passwords in
        let passwords =
          passwords
          .filter { $0.generatedDate != nil && $0.password != nil }
          .sorted { $0.sortingDate > $1.sortingDate }
          .prefix(500)
        return Dictionary(grouping: passwords) {
          DateGroup(date: $0.generatedDate ?? .init())
        }
      }
      .receive(on: DispatchQueue.main)
      .map {
        $0.isEmpty ? .empty : .loaded(passwords: $0)
      }
      .assign(to: &$state)
  }

  func copy(_ generatedPassword: GeneratedPassword) {
    pasteboardService.set(generatedPassword.password ?? "")
    logCopy(for: generatedPassword)
  }

  func logCopy(for generatedPassword: GeneratedPassword) {
    activityReporter.report(
      UserEvent.CopyVaultItemField(
        field: .password,
        isProtected: false,
        itemId: generatedPassword.userTrackingLogID,
        itemType: .generatedPassword))

    if let domain = generatedPassword.domain?.domain?.name {
      activityReporter.report(
        AnonymousEvent.CopyVaultItemField(
          domain: domain.hashedDomainForLogs(),
          field: .password,
          itemType: .generatedPassword))
    }
  }

  func makeDomainIconViewModel(url: PersonalDataURL?) -> DomainIconViewModel {
    return DomainIconViewModel(domain: url?.domain, size: .small, iconService: iconService)
  }
}

extension GeneratedPassword {
  var sortingDate: Date {
    generatedDate ?? Date()
  }
}

extension PasswordGeneratorHistoryViewModel {

  public static func mock() -> PasswordGeneratorHistoryViewModel {
    let container = MockServicesContainer()

    return PasswordGeneratorHistoryViewModel(
      database: container.database,
      userSettings: UserSettings(internalStore: .mock()),
      activityReporter: .mock,
      iconService: container.iconService)

  }
}
