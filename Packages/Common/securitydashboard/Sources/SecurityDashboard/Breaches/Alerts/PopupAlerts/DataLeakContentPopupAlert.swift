import Foundation

public struct DataLeakContentPopupAlert: PopupAlertProtocol {

  public let title: String
  public let description: AlertSection?
  public let details: AlertSection?
  public let recommendation: AlertSection?

  public let buttons: Buttons

  public let data: AlertGenerator.AlertData
}

struct DataLeakContentPopupAlertBuilder: PopupAlertBuilderProtocol {

  let data: AlertGenerator.AlertData
  let localizationProvider: LocalizationProvider

  func build() throws -> DataLeakContentPopupAlert {

    let title = try self.generateTitle(for: data, and: localizationProvider)
    let description = try self.generateDescription(for: data, and: localizationProvider)
    let details = try self.generateDetails(for: data, and: localizationProvider)
    let buttons = try self.generateButtons(for: data, and: localizationProvider)

    return DataLeakContentPopupAlert(
      title: title,
      description: description,
      details: details,
      recommendation: nil,
      buttons: buttons,
      data: data)
  }
}

extension DataLeakContentPopupAlertBuilder {
  func generateDescription(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {
    return nil
  }
}

extension DataLeakContentPopupAlertBuilder {

  func generateDetails(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {

    let details = AlertBuildersUtils.UserDataDetails(
      emailsKey: .popupBreachDetailsEmails,
      domainsKey: .popupBreachDetailsDomains,
      usernamesKey: .popupBreachDetailsUsernames)
    let dataInvolvedDetails = AlertBuildersUtils.DataInvolvedDetails(titleKey: .popupBreachDetails)
    return try AlertBuildersUtils.generateUserDataDetails(
      for: alertData, and: localizationProvider, using: details, and: dataInvolvedDetails)
  }
}

extension DataLeakContentPopupAlertBuilder {

  func generateButtons(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> Buttons {

    if alertData.numberOfCompromisedCredentials == 0 {
      return Buttons(left: nil, right: .close)
    }

    if alertData.alertType.isDataLeakAlert {
      return Buttons(left: .dismiss, right: .takeAction)
    }

    return Buttons(left: .close, right: .view)
  }
}
