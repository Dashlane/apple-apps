import CorePersonalData
import DashTypes
import Foundation

class BreachViewModel: ObservableObject, SessionServicesInjecting {
  let hasBeenAddressed: Bool
  let url: PersonalDataURL
  let leakedPassword: String?
  let leakDate: Date?
  let iconViewModel: DWMItemIconViewModelProtocol
  let email: String?
  let otherLeakedData: [String]?
  let simplifiedBreach: DWMSimplifiedBreach?

  var hasBeenViewed: Bool {
    return simplifiedBreach?.status != .pending || hasBeenAddressed == true
  }

  var label: String {
    if hasBeenAddressed {
      return L10n.Localizable.dwmOnboardingFixBreachesMainSecured
    }

    if leakedPassword != nil {
      return L10n.Localizable.dwmOnboardingFixBreachesMainPasswordFound
    } else {
      return L10n.Localizable.dwmOnboardingFixBreachesMainBreached
    }
  }

  var displayDate: String {
    guard let date = leakDate else {
      return L10n.Localizable.darkWebMonitoringBreachViewDateUnknown
    }
    return DateFormatter.mediumDateFormatter.string(from: date)
  }

  var displayLeakedData: String? {
    return otherLeakedData?.joined(separator: ", ")
  }

  init(
    hasBeenAddressed: Bool,
    url: PersonalDataURL,
    leakedPassword: String?,
    leakDate: Date?,
    email: String? = nil,
    otherLeakedData: [String]? = nil,
    simplifiedBreach: DWMSimplifiedBreach? = nil,
    iconViewModelProvider: @escaping (PersonalDataURL) -> DWMItemIconViewModel
  ) {
    self.hasBeenAddressed = hasBeenAddressed
    self.url = url
    self.leakedPassword = leakedPassword
    self.leakDate = leakDate
    self.iconViewModel = iconViewModelProvider(url)
    self.email = email
    self.otherLeakedData = otherLeakedData
    self.simplifiedBreach = simplifiedBreach
  }

  convenience init(
    breach: DWMSimplifiedBreach,
    iconViewModelProvider: @escaping (PersonalDataURL) -> DWMItemIconViewModel
  ) {
    self.init(
      hasBeenAddressed: false, url: breach.url, leakedPassword: breach.leakedPassword,
      leakDate: breach.date, email: breach.email, otherLeakedData: breach.otherLeakedData,
      simplifiedBreach: breach, iconViewModelProvider: iconViewModelProvider)
  }

  convenience init(
    credential: Credential,
    iconViewModelProvider: @escaping (PersonalDataURL) -> DWMItemIconViewModel
  ) {
    assert(credential.url != nil)
    self.init(
      hasBeenAddressed: true, url: credential.url ?? PersonalDataURL(rawValue: ""),
      leakedPassword: nil, leakDate: nil, iconViewModelProvider: iconViewModelProvider)
  }

  private init(breach: DWMSimplifiedBreach, hasBeenAddressed: Bool = false) {
    self.hasBeenAddressed = hasBeenAddressed
    self.url = breach.url
    self.leakedPassword = breach.leakedPassword
    self.leakDate = breach.date
    self.iconViewModel = FakeDWMItemIconViewModel(url: breach.url)
    self.email = breach.email
    self.otherLeakedData = breach.otherLeakedData
    self.simplifiedBreach = breach
  }

  private init(credential: Credential) {
    self.hasBeenAddressed = true
    self.url = credential.url ?? PersonalDataURL(rawValue: "")
    self.leakedPassword = nil
    self.leakDate = nil
    self.iconViewModel = FakeDWMItemIconViewModel(
      url: credential.url ?? PersonalDataURL(rawValue: ""))
    self.email = nil
    self.otherLeakedData = nil
    self.simplifiedBreach = nil
  }
}

extension BreachViewModel {
  static func mock(
    for breach: DWMSimplifiedBreach,
    hasBeenAddressed: Bool = false
  ) -> BreachViewModel {
    return BreachViewModel(breach: breach, hasBeenAddressed: hasBeenAddressed)
  }

  static func mock(for credential: Credential) -> BreachViewModel {
    return BreachViewModel(credential: credential)
  }
}
