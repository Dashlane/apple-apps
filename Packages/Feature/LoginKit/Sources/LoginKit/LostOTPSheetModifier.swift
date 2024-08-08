#if canImport(UIKit)
  import Foundation
  import CoreSession
  import SwiftUI
  import SwiftTreats
  import UIDelight
  import Combine
  import UIComponents
  import CoreLocalization
  import DashlaneAPI

  public struct LostOTPSheetModifier: ViewModifier {

    public enum Context {
      case login
      case disable2fa

      var title: String {
        switch self {
        case .login:
          return L10n.Core.otpRecoveryCannotAccessCodes
        case .disable2fa:
          return L10n.Core.otpRecoveryDisableCannotAccessCodesTitle
        }
      }
      var sheetCta: String {
        switch self {
        case .login:
          return L10n.Core.otpRecoveryUseBackupCode
        case .disable2fa:
          return L10n.Core.disableOtpUseRecoveryCode
        }
      }
      var alertCta: String {
        switch self {
        case .login:
          return L10n.Core.otpRecoveryUseBackupCodeCta
        case .disable2fa:
          return L10n.Core.disableOtpUseRecoveryCodeCta
        }
      }

      var smsMessage: String {
        switch self {
        case .login:
          return L10n.Core.otpRecoverySendFallbackSmsDescription
        case .disable2fa:
          return L10n.Core.otpRecoveryDisableSendFallbackSmsMessage
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
        message: .init(L10n.Core.otpRecoveryCannotAccessCodesDescription),
        buttons: [
          ActionSheet.Button.default(
            .init(context.sheetCta),
            action: {
              lostOTPSheetViewModel.textfieldAlertItem = .recoveryCode
            }),
          ActionSheet.Button.default(
            .init(L10n.Core.otpRecoveryReset2Fa),
            action: {
              lostOTPSheetViewModel.alertStep = .sendRecoveryKeyBySMS
            }),
          ActionSheet.Button.cancel(),
        ])
    }

    private var sendRecoveryCodesBySmsAlert: Alert {
      Alert(
        title: .init(L10n.Core.otpRecoverySendFallbackSmsTitle),
        message: .init(context.smsMessage),
        primaryButton: .default(
          .init(L10n.Core.kwSend),
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
          title: .init(L10n.Core.kwErrorTitle),
          message: .init(L10n.Core.otpRecoverySendFallbackSmsNoPhoneNumber),
          dismissButton: .default(
            .init(L10n.Core.kwButtonOk),
            action: { lostOTPSheetViewModel.recoverConfirmationError = nil }))
      default:
        return Alert(
          title: .init(L10n.Core.kwErrorTitle),
          message: .init(L10n.Core.kwExtSomethingWentWrong),
          dismissButton: .default(
            .init(L10n.Core.kwButtonOk),
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
          return L10n.Core.otpRecoveryUseBackupCodeTitle
        case .smsCode:
          return L10n.Core.otpRecoveryDisableCannotAccessCodesTitle
        }
      }

      var message: String {
        switch self {
        case .recoveryCode:
          return L10n.Core.otpRecoveryUseBackupCodeDescription
        case .smsCode:
          return L10n.Core.otpRecoveryDisableCannotAccessCodesDescription
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
        content
          .modifier(
            AlertTextFieldModifier(
              item: $item,
              textFieldInput: $inputBackupCode,
              title: item.title,
              message: item.message,
              placeholder: L10n.Core.otpRecoveryEnterBackupCode,
              buttons: {
                HStack {
                  Button(L10n.Core.cancel) {
                    self.item = nil
                  }
                  .buttonStyle(AlertButtonStyle(mainButton: false))
                  Divider()
                  Button(context.alertCta) {
                    guard !inputBackupCode.isEmpty else { return }
                    self.item = nil
                    useBackupCode(inputBackupCode)
                  }
                }
              }))
      } else {
        content
      }
    }
  }
#endif
