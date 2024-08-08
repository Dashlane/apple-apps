import Foundation

protocol TrayAlertBuilderProtocol: AlertBuilderProtocol {
  func generateTimestamp(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> String?
  func generateDate(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection?
}

extension TrayAlertBuilderProtocol {

  func generateTitle(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> String {
    let alertTitle = AlertBuildersUtils.AlertTitle(
      dataLeakTitleKey: .trayDataLeakTitle,
      regularAlertTitleKey: .trayRegularTitle,
      dataContentTitleKey: .trayDataLeakNewTitle)
    return try AlertBuildersUtils.generateTitle(
      for: alertData, and: localizationProvider, details: alertTitle)
  }
}

extension TrayAlertBuilderProtocol {
  func generateDescription(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {
    return nil
  }
}

extension TrayAlertBuilderProtocol {

  func generateDetails(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {
    let details = AlertBuildersUtils.DataInvolvedDetails(titleKey: .trayBreachDetails)
    return try AlertBuildersUtils.generateDataInvolvedDetails(
      for: alertData, and: localizationProvider, details: details)
  }
}

extension TrayAlertBuilderProtocol {
  func generateRecommendation(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {
    return nil
  }
}

extension TrayAlertBuilderProtocol {

  func generateTimestamp(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> String? {

    guard let breachCreationDate = breach.creationDate else {
      throw AlertGenerator.AlertError.breachDoesNotHaveACreationDate
    }

    let dateDistance = Date().timeIntervalSince1970 - breachCreationDate

    switch dateDistance {
    case 0...TimeInterval.oneHour:
      return localizationProvider.localizedString(for: .trayWhenJustNow)
    case TimeInterval.oneHour...TimeInterval.oneDay:
      return localizationProvider.localizedString(for: .trayWhenToday)
    case TimeInterval.oneDay...TimeInterval.twoDays:
      return localizationProvider.localizedString(for: .trayWhenYesterday)
    default:
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .long
      dateFormatter.timeStyle = .none
      return dateFormatter.string(from: Date(timeIntervalSince1970: breachCreationDate))
    }

  }
}

extension TimeInterval {
  fileprivate static let oneHour: Double = 3600
  fileprivate static let oneDay: Double = 86400
  fileprivate static let twoDays: Double = 172800
}

extension TrayAlertBuilderProtocol {
  func generateDate(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {
    guard let breachCreationDate = breach.eventDate?.readableString else {
      return nil
    }
    return AlertSection(
      title: AlertSection.Title(localizationProvider.localizedString(for: .trayDate)),
      contents: [breachCreationDate])
  }
}
