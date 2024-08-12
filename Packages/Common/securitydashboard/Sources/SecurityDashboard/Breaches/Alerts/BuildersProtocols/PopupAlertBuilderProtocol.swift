import Foundation

protocol PopupAlertBuilderProtocol: AlertBuilderProtocol {
}

extension PopupAlertBuilderProtocol {

  func generateTitle(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> String {
    let alertTitle = AlertBuildersUtils.AlertTitle(
      dataLeakTitleKey: .popupDataLeakTitle,
      regularAlertTitleKey: .popupRegularTitle,
      dataContentTitleKey: .popupDataLeakNewTitle)
    return try AlertBuildersUtils.generateTitle(
      for: alertData, and: localizationProvider, details: alertTitle)
  }
}

extension PopupAlertBuilderProtocol {

  func generateDetails(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {
    let details = AlertBuildersUtils.DataInvolvedDetails(titleKey: .popupBreachDetails)
    return try AlertBuildersUtils.generateDataInvolvedDetails(
      for: alertData, and: localizationProvider, details: details)
  }
}

extension PopupAlertBuilderProtocol {
  func generateRecommendation(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider
  ) throws -> AlertSection? {
    return nil
  }
}
