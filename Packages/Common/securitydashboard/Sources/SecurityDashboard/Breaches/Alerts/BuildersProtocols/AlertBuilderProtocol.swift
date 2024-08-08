import Foundation

protocol AlertBuilderProtocol {

  associatedtype Alert

  var breach: Breach { get }
  var data: AlertGenerator.AlertData { get }
  var localizationProvider: LocalizationProvider { get }

  init(data: AlertGenerator.AlertData, localizationProvider: LocalizationProvider)
  func build() throws -> Alert

  func generateTitle(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> String
  func generateDescription(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection?
  func generateDetails(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection?
  func generateRecommendation(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection?
  func generateButtons(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> Buttons
}

extension AlertBuilderProtocol {
  var breach: Breach { return data.breach }
}

extension LocalizationKey {
  static func key(for leakedData: LeakedData) -> LocalizationKey? {
    switch leakedData {
    case .email: return .dataTypeEmails
    case .address: return .dataTypeAddresses
    case .password: return .dataTypePasswords
    case .social: return .dataTypeSocial
    case .ssn: return .dataTypeSsn
    case .creditCard: return .dataTypeCreditCard
    case .phoneNumber: return .dataTypePhoneNumber
    case .username: return .dataTypeUsername
    case .ip: return .dataTypeIp
    case .geolocation: return .dataTypeGeolocation
    case .personalInfo: return .dataTypePersonalInfo
    case .unknown: return nil
    }
  }
}
