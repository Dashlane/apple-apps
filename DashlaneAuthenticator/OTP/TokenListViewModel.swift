import AuthenticatorKit
import Combine
import CorePersonalData
import DashTypes
import Foundation
import IconLibrary
import TOTPGenerator

class TokenListViewModel: ObservableObject {
  @Published
  var tokens = [OTPInfo]()

  @Published
  var favorites = [OTPInfo]()

  @Published
  var popoverItem: OTPInfo?

  var cancellables = Set<AnyCancellable>()

  let databaseService: AuthenticatorDatabaseServiceProtocol
  let didDelete: (OTPInfo) -> Void
  let tokenRowViewModelFactory: TokenRowViewModel.Factory
  let daysBeforeSunset: Int

  @Published
  var steps: [Step] = []

  enum Step: Identifiable {
    case list
    case detail(OTPInfo)
    case help
    case sunset

    var id: String {
      switch self {
      case .list:
        return "list"
      case .help:
        return "help"
      case let .detail(item):
        return item.id.rawValue
      case .sunset:
        return "sunset"
      }
    }
  }

  init(
    databaseService: AuthenticatorDatabaseServiceProtocol,
    tokenRowViewModelFactory: TokenRowViewModel.Factory,
    didDelete: @escaping (OTPInfo) -> Void
  ) {
    self.databaseService = databaseService
    self.tokenRowViewModelFactory = tokenRowViewModelFactory
    self.didDelete = didDelete

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    if let sunsetDate = formatter.date(from: "2024/05/13 00:00") {
      self.daysBeforeSunset = max(0, Int(sunsetDate.timeIntervalSinceNow / (60 * 60 * 24)))
    } else {
      self.daysBeforeSunset = 0
    }

    databaseService.codesPublisher
      .map({ $0.sortedByIssuer() })
      .map { $0.separateByIsFavorite() }
      .sink(receiveValue: { codes in
        self.tokens = codes[false] ?? []
        self.favorites = codes[true] ?? []
      })
      .store(in: &cancellables)
    steps.append(.list)
  }

  func makeTokenRowViewModel(for token: OTPInfo) -> TokenRowViewModel {
    return tokenRowViewModelFactory.make(
      token: token, dashlaneTokenCaption: L10n.Localizable.dashlanePairedTitle)
  }

  func delete(item: OTPInfo) {
    do {
      try databaseService.delete(item)
      self.didDelete(item)
    } catch {
      assertionFailure()
    }
  }

  func update(item: OTPInfo) {
    do {
      try databaseService.update(item)
    } catch {
      assertionFailure()
    }
  }

  func showHelp() {
    steps.append(.help)
  }

  func showSunset() {
    steps.append(.sunset)
  }
}

extension [OTPInfo] {
  func separateByIsFavorite() -> [Bool: [OTPInfo]] {
    self.reduce(into: [Bool: [OTPInfo]]()) { partialResult, otpInfo in
      partialResult[otpInfo.isFavorite, default: []].append(otpInfo)
    }
  }
}

extension TokenListViewModel: AuthenticatorServicesInjecting {}
extension TokenListViewModel: AuthenticatorMockInjecting {}

extension TokenListViewModel {
  static func mock() -> TokenListViewModel {
    AuthenticatorMockContainer().makeTokenListViewModel { _ in

    }
  }
}
