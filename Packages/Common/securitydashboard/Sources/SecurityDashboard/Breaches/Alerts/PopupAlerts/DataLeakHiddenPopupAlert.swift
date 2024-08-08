import Foundation

public struct DataLeakHiddenPopupAlert: PopupAlertProtocol {

  public let title: String
  public let description: AlertSection?
  public let details: AlertSection?
  public let recommendation: AlertSection?

  public let explanations: AlertSection?

  public let buttons: Buttons

  public let date: AlertSection?

  public let data: AlertGenerator.AlertData
}

struct DataLeakHiddenPopupAlertBuilder: PopupAlertBuilderProtocol {

  let data: AlertGenerator.AlertData
  let localizationProvider: LocalizationProvider

  func build() throws -> DataLeakHiddenPopupAlert {

    let title = try self.generateTitle(for: data, and: localizationProvider)
    let description = try self.generateDescription(for: data, and: localizationProvider)
    let details = try self.generateDetails(for: data, and: localizationProvider)
    let explanations = try self.generateExplanations(for: data, and: localizationProvider)
    let buttons = try self.generateButtons(for: data, and: localizationProvider)
    let date = try self.generateDate(for: data, and: localizationProvider)

    return DataLeakHiddenPopupAlert(
      title: title,
      description: description,
      details: details,
      recommendation: nil,
      explanations: explanations,
      buttons: buttons,
      date: date,
      data: data)
  }
}

extension DataLeakHiddenPopupAlertBuilder {

  func generateTitle(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> String {
    return localizationProvider.localizedString(for: .popupDataLeakHidden)
  }
}

extension DataLeakHiddenPopupAlertBuilder {
  func generateDescription(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {

    guard let breachDate = breach.eventDate?.readableString else { return nil }

    return AlertSection(
      title: AlertSection.Title(
        localizationProvider.localizedString(for: .popupDataLeakHiddenDescription)),
      contents: [breachDate])
  }
}

extension DataLeakHiddenPopupAlertBuilder {
  func generateExplanations(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {

    guard alertData.alertType == .dataLeakAlertHiddenContent else { return nil }

    return AlertSection(
      title: AlertSection.Title(
        localizationProvider.localizedString(for: .popupExplanationDataLeakTitle)),
      contents: [localizationProvider.localizedString(for: .popupExplanationDataLeakDescription)])
  }
}

extension DataLeakHiddenPopupAlertBuilder {
  func generateButtons(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> Buttons {
    return Buttons(left: .cancel, right: .upgrade)
  }
}

extension DataLeakHiddenPopupAlertBuilder {
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
