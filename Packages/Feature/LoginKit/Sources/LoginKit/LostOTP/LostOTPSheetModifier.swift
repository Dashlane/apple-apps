import Combine
import CoreLocalization
import CoreSession
import DashlaneAPI
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct LostOTPSheetModifier: ViewModifier {

  public enum Context {
    case login
    case disable2fa

    var title: String {
      switch self {
      case .login:
        return CoreL10n.otpRecoveryCannotAccessCodes
      case .disable2fa:
        return CoreL10n.otpRecoveryDisableCannotAccessCodesTitle
      }
    }
    var sheetCta: String {
      switch self {
      case .login:
        return CoreL10n.otpRecoveryUseBackupCode
      case .disable2fa:
        return CoreL10n.disableOtpUseRecoveryCode
      }
    }
    var alertCta: String {
      switch self {
      case .login:
        return CoreL10n.otpRecoveryUseBackupCodeCta
      case .disable2fa:
        return CoreL10n.disableOtpUseRecoveryCodeCta
      }
    }

    var smsMessage: String {
      switch self {
      case .login:
        return CoreL10n.otpRecoverySendFallbackSmsDescription
      case .disable2fa:
        return CoreL10n.otpRecoveryDisableSendFallbackSmsMessage
      }
    }
  }

  @Binding
  var isLostOTPSheetDisplayed: Bool

  @State
  var inputBackupCode = ""

  let useBackupCode: (String) -> Void

  @ObservedObject
  var lostOTPSheetViewModel: LostOTPSheetViewModel

  let context: Context

  public init(
    isLostOTPSheetDisplayed: Binding<Bool>,
    useBackupCode: @escaping (String) -> Void,
    lostOTPSheetViewModel: LostOTPSheetViewModel,
    context: Context = .login
  ) {
    self._isLostOTPSheetDisplayed = isLostOTPSheetDisplayed
    self.useBackupCode = useBackupCode
    self.lostOTPSheetViewModel = lostOTPSheetViewModel
    self.context = context
  }

  public func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity)
      .actionSheet(
        isPresented: $isLostOTPSheetDisplayed,
        content: { actionSheet }
      )
      .alert(item: $lostOTPSheetViewModel.alertStep) { item in
        if item == .sendRecoveryKeyBySMS {
          return sendRecoveryCodesBySmsAlert
        } else {
          return recoveryCodesConfirmationAlert
        }
      }
      .modifier(
        RecoveryTextfieldAlertModifier(
          item: $lostOTPSheetViewModel.textfieldAlertItem, inputBackupCode: $inputBackupCode,
          context: context, useBackupCode: useBackupCode))
  }

  private var actionSheet: ActionSheet {
    ActionSheet(
      title: .init(context.title),
      message: .init(CoreL10n.otpRecoveryCannotAccessCodesDescription),
      buttons: [
        ActionSheet.Button.default(
          .init(context.sheetCta),
          action: {
            lostOTPSheetViewModel.textfieldAlertItem = .recoveryCode
          }),
        ActionSheet.Button.default(
          .init(CoreL10n.otpRecoveryReset2Fa),
          action: {
            lostOTPSheetViewModel.alertStep = .sendRecoveryKeyBySMS
          }),
        ActionSheet.Button.cancel(),
      ])
  }

  private var sendRecoveryCodesBySmsAlert: Alert {
    Alert(
      title: .init(CoreL10n.otpRecoverySendFallbackSmsTitle),
      message: .init(context.smsMessage),
      primaryButton: .default(
        .init(CoreL10n.kwSend),
        action: { lostOTPSheetViewModel.recoverCodes() }),
      secondaryButton: .cancel())
  }

  private var recoveryCodesConfirmationAlert: Alert {
    guard let error = lostOTPSheetViewModel.recoverConfirmationError else {
      fatalError()
    }
    switch error {
    case let error as APIError where error.hasAuthenticationCode(.wrongOTPStatus):
      return Alert(
        title: .init(CoreL10n.kwErrorTitle),
        message: .init(CoreL10n.otpRecoverySendFallbackSmsNoPhoneNumber),
        dismissButton: .default(
          .init(CoreL10n.kwButtonOk),
          action: { lostOTPSheetViewModel.recoverConfirmationError = nil }))
    default:
      return Alert(
        title: .init(CoreL10n.kwErrorTitle),
        message: .init(CoreL10n.kwExtSomethingWentWrong),
        dismissButton: .default(
          .init(CoreL10n.kwButtonOk),
          action: { lostOTPSheetViewModel.recoverConfirmationError = nil }))
    }
  }
}

struct RecoveryTextfieldAlertModifier: ViewModifier {

  enum Item: String, Identifiable {
    case recoveryCode
    case smsCode
    var id: String {
      rawValue
    }

    var title: String {
      switch self {
      case .recoveryCode:
        return CoreL10n.otpRecoveryUseBackupCodeTitle
      case .smsCode:
        return CoreL10n.otpRecoveryDisableCannotAccessCodesTitle
      }
    }

    var message: String {
      switch self {
      case .recoveryCode:
        return CoreL10n.otpRecoveryUseBackupCodeDescription
      case .smsCode:
        return CoreL10n.otpRecoveryDisableCannotAccessCodesDescription
      }
    }
  }

  @Binding
  var item: Item?

  @Binding
  var inputBackupCode: String

  let context: LostOTPSheetModifier.Context
  let useBackupCode: (String) -> Void

  func body(content: Content) -> some View {
    if let item = item {
      content.modifier(
        LostOTPAlertModifier(
          item: $item,
          textFieldInput: $inputBackupCode,
          title: item.title,
          message: item.message,
          placeholder: CoreL10n.otpRecoveryEnterBackupCode
        ) {
          Button(CoreL10n.cancel, role: .cancel) {
            self.item = nil
          }

          Button(context.alertCta) {
            guard !inputBackupCode.isEmpty else { return }
            self.item = nil
            useBackupCode(inputBackupCode)
          }
        }
      )
    } else {
      content
    }
  }
}
