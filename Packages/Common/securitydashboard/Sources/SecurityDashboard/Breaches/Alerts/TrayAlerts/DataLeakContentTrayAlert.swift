import Foundation

public struct DataLeakContentTrayAlert: TrayAlertProtocol {

  public let title: String
  public let description: AlertSection?
  public let details: AlertSection?
  public let recommendation: AlertSection?

  public let buttons: Buttons

  public let timestamp: String?
  public let date: AlertSection?

  public let data: AlertGenerator.AlertData
}

struct DataLeakContentTrayAlertBuilder: TrayAlertBuilderProtocol {

  let data: AlertGenerator.AlertData
  let localizationProvider: LocalizationProvider

  func build() throws -> DataLeakContentTrayAlert {

    let title = try self.generateTitle(for: data, and: localizationProvider)
    let details = try self.generateDetails(for: data, and: localizationProvider)
    let buttons = try self.generateButtons(for: data, and: localizationProvider)
    let timestamp = try self.generateTimestamp(for: data, and: localizationProvider)
    let date = try self.generateDate(for: data, and: localizationProvider)

    return DataLeakContentTrayAlert(
      title: title,
      description: nil,
      details: details,
      recommendation: nil,
      buttons: buttons,
      timestamp: timestamp,
      date: date,
      data: data)
  }
}

extension DataLeakContentTrayAlertBuilder {

  func generateDetails(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {
    let details = AlertBuildersUtils.UserDataDetails(
      emailsKey: .trayBreachDetailsEmails,
      domainsKey: .trayBreachDetailsDomains,
      usernamesKey: .trayBreachDetailsUsernames)
    return try AlertBuildersUtils.generateUserDataDetails(
      for: alertData, and: localizationProvider, using: details)
  }
}

extension DataLeakContentTrayAlertBuilder {

  func generateButtons(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> Buttons {

    if alertData.numberOfCompromisedCredentials == 0 {
      return Buttons(left: nil, right: .close)
    }

    if alertData.alertType.isDataLeakAlert {
      return Buttons(left: nil, right: .takeAction)
    }

    return Buttons(left: nil, right: .view)
  }
}
