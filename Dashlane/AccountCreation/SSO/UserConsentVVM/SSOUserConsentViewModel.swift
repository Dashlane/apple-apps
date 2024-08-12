import Foundation
import SwiftUI
import UIKit

class SSOUserConsentViewModel: UserConsentViewModelProtocol, ObservableObject {
  @Published
  var hasUserAcceptedEmailMarketing: Bool = false

  @Published
  var hasUserAcceptedTermsAndConditions: Bool = false

  @Published
  var shouldDisplayMissingRequiredConsentAlert: Bool = false

  @Published
  var isAccountCreationRequestInProgress = false

  let userCountryProvider: UserCountryProvider
  let completion: (Completion) -> Void

  enum Completion {
    case finished(_ hasUserAcceptedTermsAndConditions: Bool, _ hasUserAcceptedEmailMarketing: Bool)
    case cancel
  }

  init(
    userCountryProvider: UserCountryProvider,
    completion: @escaping (Completion) -> Void
  ) {
    self.userCountryProvider = userCountryProvider
    self.completion = completion

    Task {
      await optIntMarketing()
    }
  }

  func optIntMarketing() async {
    let isEU = await userCountryProvider.userCountry.isEu
    if !isEU {
      self.hasUserAcceptedEmailMarketing = true
    }
  }

  func signup() {
    guard hasUserAcceptedTermsAndConditions else {
      shouldDisplayMissingRequiredConsentAlert = true
      return
    }
    isAccountCreationRequestInProgress = true
    completion(.finished(hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing))
  }

  func cancel() {
    completion(.cancel)
  }
}
