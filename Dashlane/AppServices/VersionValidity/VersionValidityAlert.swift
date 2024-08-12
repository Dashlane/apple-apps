import Foundation
import SwiftUI
import UIDelight
import UIKit

struct VersionValidityAlert {

  private let status: VersionValidityStatus
  private let alertDismissed: () -> Void

  init(status: VersionValidityStatus, alertDismissed: @escaping () -> Void) {
    self.status = status
    self.alertDismissed = alertDismissed
  }

  func makeAlert() -> UIAlertController? {
    switch status {
    case .valid:
      return nil
    case .updateRecommended(let updatePossible):
      return makeAlertForUpdateRecommended(updatePossible: updatePossible)
    case .updateStronglyEncouraged(let updatePossible, let helpCenterUrl):
      return makeAlertForUpdateStronglyEncouraged(
        updatePossible: updatePossible, helpCenterUrl: helpCenterUrl)
    case .updateRequired(let updatePossible, let daysBeforeExpiration, let helpCenterUrl):
      if let daysBeforeExpiration = daysBeforeExpiration {
        return makeAlertForUpdateRequired(
          updatePossible: updatePossible, daysBeforeExpiration: daysBeforeExpiration,
          helpCenterUrl: helpCenterUrl)
      } else {
        return makeAlertForUpdateStronglyEncouraged(
          updatePossible: updatePossible, helpCenterUrl: helpCenterUrl)
      }
    case .expired(let updatePossible, let helpCenterUrl):
      return makeAlertForExpired(updatePossible: updatePossible, helpCenterUrl: helpCenterUrl)
    }
  }

  private func makeAlertForExpired(updatePossible: Bool, helpCenterUrl: String)
    -> UIAlertController?
  {
    if updatePossible == true {
      return makeAlert(
        title: L10n.Localizable.validityStatusExpiredVersionUpdatePossibleTitle,
        message: L10n.Localizable.validityStatusExpiredVersionUpdatePossibleDesc,
        primaryActionTitle: L10n.Localizable.validityStatusExpiredVersionUpdatePossibleUpdate,
        primaryAction: openAppStore,
        secondaryActionTitle: L10n.Localizable.validityStatusExpiredVersionUpdatePossibleClose)
    } else {
      return makeAlert(
        title: L10n.Localizable.validityStatusExpiredVersionNoUpdateTitle,
        message: L10n.Localizable.validityStatusExpiredVersionNoUpdateDesc,
        primaryActionTitle: L10n.Localizable.validityStatusExpiredVersionNoUpdateLearnMore,
        primaryAction: { openHelpCenter(url: helpCenterUrl) },
        secondaryActionTitle: L10n.Localizable.validityStatusExpiredVersionNoUpdateClose)
    }
  }

  private func makeAlertForUpdateRequired(
    updatePossible: Bool, daysBeforeExpiration: Int, helpCenterUrl: String
  ) -> UIAlertController? {
    if updatePossible == true {
      return makeAlert(
        title: L10n.Localizable.validityStatusUpdateRequiredUpdatePossibleTitle,
        message: L10n.Localizable.validityStatusUpdateRequiredUpdatePossibleDesc(
          String(daysBeforeExpiration)),
        primaryActionTitle: L10n.Localizable.validityStatusUpdateRequiredUpdatePossibleUpdate,
        primaryAction: openAppStore,
        secondaryActionTitle: L10n.Localizable.validityStatusUpdateRequiredUpdatePossibleClose)
    } else {
      return makeAlert(
        title: L10n.Localizable.validityStatusUpdateRequiredNoUpdateTitle,
        message: L10n.Localizable.validityStatusUpdateRequiredNoUpdateDesc(
          String(daysBeforeExpiration)),
        primaryActionTitle: L10n.Localizable.validityStatusUpdateRequiredNoUpdateLearnMore,
        primaryAction: { openHelpCenter(url: helpCenterUrl) },
        secondaryActionTitle: L10n.Localizable.validityStatusUpdateRequiredNoUpdateClose)
    }
  }

  private func makeAlertForUpdateStronglyEncouraged(updatePossible: Bool, helpCenterUrl: String)
    -> UIAlertController?
  {
    if updatePossible == true {
      return makeAlert(
        title: L10n.Localizable.validityStatusUpdateStronglyEncouragedUpdatePossibleTitle,
        message: L10n.Localizable.validityStatusUpdateStronglyEncouragedUpdatePossibleDesc,
        primaryActionTitle: L10n.Localizable
          .validityStatusUpdateStronglyEncouragedUpdatePossibleUpdate,
        primaryAction: openAppStore,
        secondaryActionTitle: L10n.Localizable
          .validityStatusUpdateStronglyEncouragedUpdatePossibleClose)
    } else {
      return makeAlert(
        title: L10n.Localizable.validityStatusUpdateStronglyEncouragedNoUpdateTitle,
        message: L10n.Localizable.validityStatusUpdateStronglyEncouragedNoUpdateDesc,
        primaryActionTitle: L10n.Localizable
          .validityStatusUpdateStronglyEncouragedNoUpdateLearnMore,
        primaryAction: { openHelpCenter(url: helpCenterUrl) },
        secondaryActionTitle: L10n.Localizable.validityStatusUpdateStronglyEncouragedNoUpdateClose)
    }
  }

  private func makeAlertForUpdateRecommended(updatePossible: Bool) -> UIAlertController? {
    if updatePossible == true {
      return makeAlert(
        title: L10n.Localizable.validityStatusUpdateRecommendedUpdatePossibleTitle,
        message: nil,
        primaryActionTitle: L10n.Localizable.validityStatusUpdateRecommendedUpdatePossibleUpdate,
        primaryAction: openAppStore,
        secondaryActionTitle: L10n.Localizable.validityStatusUpdateRecommendedUpdatePossibleClose)
    } else {
      return nil
    }
  }

  private func makeAlert(
    title: String, message: String?, primaryActionTitle: String,
    primaryAction: @escaping () -> Void, secondaryActionTitle: String
  ) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let primaryAction = UIAlertAction(
      title: primaryActionTitle, style: .default,
      handler: { _ in
        primaryAction()
        alertDismissed()
      })
    let secondaryAction = UIAlertAction(
      title: secondaryActionTitle, style: .default,
      handler: { _ in
        alertDismissed()
      })
    alert.addAction(secondaryAction)
    alert.addAction(primaryAction)
    return alert
  }

  private func openAppStore() {
    guard let appUrl = URL(string: "itms-apps://itunes.apple.com/app/id517914548") else {
      assertionFailure()
      return
    }
    UIApplication.shared.open(appUrl)
  }

  private func openHelpCenter(url: String) {
    UIApplication.shared.open(URL(string: url)!)
  }
}

extension VersionValidityAlert {
  static func errorAlert() -> UIAlertController {
    let alert = UIAlertController(
      title: L10n.Localizable.validityStatusExpiredVersionNoUpdateTitle,
      message: L10n.Localizable.validityStatusExpiredVersionNoUpdateDesc,
      preferredStyle: .alert)
    let action = UIAlertAction(
      title: L10n.Localizable.validityStatusExpiredVersionNoUpdateClose,
      style: .default)
    alert.addAction(action)
    return alert
  }

  static func errorAlert() -> AlertContent {
    return .init(
      title: L10n.Localizable.validityStatusExpiredVersionNoUpdateTitle,
      message: L10n.Localizable.validityStatusExpiredVersionNoUpdateDesc,
      buttons: .one(.init(title: L10n.Localizable.validityStatusExpiredVersionNoUpdateClose)))
  }

  static func errorAlert() -> Alert {
    return .init(
      title: Text(L10n.Localizable.validityStatusExpiredVersionNoUpdateTitle),
      message: Text(L10n.Localizable.validityStatusExpiredVersionNoUpdateDesc),
      dismissButton: .cancel(Text(L10n.Localizable.validityStatusExpiredVersionNoUpdateClose)))
  }
}
