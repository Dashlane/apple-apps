import CorePersonalData
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

@MainActor
protocol AutoFillDemoHandler {
  func showAutofillDemo(for credential: Credential)
  func handleAutofillDemoDummyFieldsAction(_ action: AutoFillDemoDummyFields.Completion)
}

@MainActor
extension AutoFillDemoHandler {
  func autofillDemoDummyFields(
    credential: Credential,
    completion: @escaping (AutoFillDemoDummyFields.Completion) -> Void
  ) -> AutoFillDemoDummyFields {
    AutoFillDemoDummyFields(
      autoFillDomain: credential.url?.displayDomain ?? credential.title,
      autoFillEmail: credential.email,
      autoFillPassword: credential.password,
      completion: completion
    )
  }

  func showAutofillDemo(
    for credential: Credential, modal: @escaping () -> Void, push: @escaping () -> Void
  ) {
    if Device.isIpadOrMac {
      modal()
    } else {
      push()
    }
  }
}
