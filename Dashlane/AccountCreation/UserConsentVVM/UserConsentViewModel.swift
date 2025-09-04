import Combine
import CoreLocalization
import CoreTypes
import DashlaneAPI
import DesignSystem
import Foundation
import LoginKit
import SwiftTreats
import UIKit

protocol UserConsentViewModelProtocol {
  var legalNoticeEUString: String { get }
}

@MainActor
class UserConsentViewModel: ObservableObject, UserConsentViewModelProtocol,
  AccountCreationFlowDependenciesInjecting
{
  @Published
  var hasUserAcceptedEmailMarketing: Bool = false

  @Published
  var hasUserAcceptedTermsAndConditions: Bool = false

  @Published
  var shouldDisplayMissingRequiredConsentAlert: Bool = false

  @Published
  var isAccountCreationRequestInProgress: Bool = false

  private let userCountryProvider: UserCountryProvider
  let completion: @MainActor (Completion) -> Void

  enum Completion {
    case back(hasUserAcceptedTermsAndConditions: Bool, hasUserAcceptedEmailMarketing: Bool)
    case next(hasUserAcceptedTermsAndConditions: Bool, hasUserAcceptedEmailMarketing: Bool)
  }

  init(
    userCountryProvider: UserCountryProvider,
    completion: @MainActor @escaping (UserConsentViewModel.Completion) -> Void
  ) {
    self.completion = completion
    self.userCountryProvider = userCountryProvider

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

  func back() {
    completion(
      .back(
        hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions,
        hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))
  }

  func goToTerms() {
    guard let url = URL(string: "_") else {
      return
    }
    UIApplication.shared.open(url)
  }

  func goToPrivacy() {
    guard let url = URL(string: "_") else {
      return
    }
    UIApplication.shared.open(url)
  }

  func validate() {
    if skipValidationInDebug() { return }

    guard hasUserAcceptedTermsAndConditions else {
      shouldDisplayMissingRequiredConsentAlert = true
      return
    }

    isAccountCreationRequestInProgress = true

    completion(
      .next(
        hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions,
        hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))
  }

  private func skipValidationInDebug() -> Bool {
    #if DEBUG
      if !ProcessInfo.isTesting {
        isAccountCreationRequestInProgress = true
        hasUserAcceptedEmailMarketing = true
        hasUserAcceptedTermsAndConditions = true
        completion(
          .next(
            hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions,
            hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))
        return true
      }
    #endif
    return false
  }
}

extension UserConsentViewModelProtocol {

  private static func linkAttributes(for url: URL) -> AttributeContainer {
    var attributeContainer = AttributeContainer()
    attributeContainer.link = url
    attributeContainer.underlineStyle = .single
    attributeContainer.foregroundColor = .ds.text.brand.standard
    return attributeContainer
  }

  var legalNoticeEUString: String {
    let termString = L10n.Localizable.createaccountPrivacysettingsTermsConditions
    let privacyString = CoreL10n.kwCreateAccountPrivacy
    let requiredString = L10n.Localizable.createaccountPrivacysettingsRequiredLabel

    return L10n.Localizable.minimalisticOnboardingRecapCheckboxTerms(
      termString, privacyString, requiredString)
  }
}
