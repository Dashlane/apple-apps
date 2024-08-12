import CoreSession
import DashTypes
import DashlaneAPI
import Foundation

public enum AlertStep: String, Identifiable {
  case sendRecoveryKeyBySMS
  case confirmationSentRecoveryKeyBySMS

  public var id: String { rawValue }
}

public class LostOTPSheetViewModel: ObservableObject {

  @Published
  public var alertStep: AlertStep?

  #if canImport(UIKit)
    @Published
    var textfieldAlertItem: RecoveryTextfieldAlertModifier.Item?
  #endif

  @Published
  public var recoverConfirmationError: Error? {
    didSet {
      if recoverConfirmationError != nil {
        alertStep = .confirmationSentRecoveryKeyBySMS
      } else {
        alertStep = nil
      }
    }
  }

  private let appAPIClient: AppAPIClient
  private let login: Login

  public init(appAPIClient: AppAPIClient, login: Login) {
    self.appAPIClient = appAPIClient
    self.login = login
  }

  #if canImport(UIKit)
    public func recoverCodes() {
      Task {
        do {
          try await appAPIClient.authentication.requestOtpRecoveryCodesByPhone(login: login.email)
          self.textfieldAlertItem = .smsCode
        } catch {
          self.recoverConfirmationError = error
        }

      }
    }
  #endif
}
