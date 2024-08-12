#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import CoreLocalization
  import DashTypes
  import CoreUserTracking

  struct ForgotMasterPasswordSheetModifier: ViewModifier {

    let model: ForgotMasterPasswordSheetModel

    @Binding
    var hasAccountRecoveryKey: Bool

    @Binding
    var showForgotMasterPasswordSheet: Bool

    public func body(content: Content) -> some View {
      content
        .actionSheet(
          isPresented: $showForgotMasterPasswordSheet,
          content: { actionSheet })
    }

    private var actionSheet: ActionSheet {
      ActionSheet(
        title: Text(L10n.Core.forgotMpSheetTitle),
        buttons: helpActions)
    }

    private var helpActions: [ActionSheet.Button] {
      var actions: [ActionSheet.Button] = []
      if model.hasMasterPasswordReset {
        actions.append(
          .default(
            Text(L10n.Core.resetMasterPasswordConfirmationDialogConfirm),
            action: { model.didTapResetMP?() }))
      }

      if hasAccountRecoveryKey {
        actions.append(
          .default(
            Text(L10n.Core.forgotMpSheetRecoveryActionTitle),
            action: { model.didTapAccountRecovery?() }))
      }

      if actions.isEmpty {
        actions.append(contentsOf: [
          .default(
            Text(L10n.Core.actionCannotLogin),
            action: {
              UIApplication.shared.open(DashlaneURLFactory.cannotLogin)
              self.model.logForgotPassword()
            }),
          .default(
            Text(L10n.Core.actionForgotMyPassword),
            action: {
              UIApplication.shared.open(DashlaneURLFactory.forgotPassword)
              self.model.logForgotPassword()
            }),
        ])
      }
      actions.append(.cancel())
      return actions
    }
  }

  struct ForgotMasterPasswordSheetModifier_Previews: PreviewProvider {
    static var previews: some View {
      Text("Forgot your password?")
        .modifier(
          ForgotMasterPasswordSheetModifier(
            model: ForgotMasterPasswordSheetModel(
              login: "", activityReporter: .mock, hasMasterPasswordReset: false),
            hasAccountRecoveryKey: .constant(false), showForgotMasterPasswordSheet: .constant(true))
        )
      Text("Forgot your password?")
        .modifier(
          ForgotMasterPasswordSheetModifier(
            model: ForgotMasterPasswordSheetModel(
              login: "", activityReporter: .mock, hasMasterPasswordReset: true),
            hasAccountRecoveryKey: .constant(false), showForgotMasterPasswordSheet: .constant(false)
          ))
      Text("Forgot your password?")
        .modifier(
          ForgotMasterPasswordSheetModifier(
            model: ForgotMasterPasswordSheetModel(
              login: "", activityReporter: .mock, hasMasterPasswordReset: false),
            hasAccountRecoveryKey: .constant(true), showForgotMasterPasswordSheet: .constant(true)))
      Text("Forgot your password?")
        .modifier(
          ForgotMasterPasswordSheetModifier(
            model: ForgotMasterPasswordSheetModel(
              login: "", activityReporter: .mock, hasMasterPasswordReset: true),
            hasAccountRecoveryKey: .constant(true), showForgotMasterPasswordSheet: .constant(true)))
    }
  }
#endif
