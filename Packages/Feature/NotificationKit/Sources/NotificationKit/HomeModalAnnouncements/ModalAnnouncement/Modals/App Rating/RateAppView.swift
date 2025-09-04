import CoreLocalization
import CoreTypes
import DesignSystemExtra
import MessageUI
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct RateAppView: View {

  let viewModel: RateAppViewModel

  @State
  var isMailViewPresented = false

  @State
  var isMailAlertPresented = false

  @Environment(\.dismiss) var dismiss

  public init(viewModel: RateAppViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    mainView
      .sheet(
        isPresented: $isMailViewPresented,
        onDismiss: { dismiss() },
        content: {
          MailView(model: viewModel.makeMailViewModel())
        }
      )
      .alert(
        "",
        isPresented: $isMailAlertPresented,
        actions: {
          Button(CoreL10n.kwButtonOk) {
            dismiss()
          }
        },
        message: {
          Text(CoreL10n.kwSharingNoEmailAccount)
        }
      )
      .onAppear {
        viewModel.markRateAppHasBeenShown()
      }
  }

  private var mainView: some View {
    NativeAlert(spacing: 10) {
      Image(.sendLove)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(Color.ds.text.brand.standard)
        .padding(.horizontal, 70.0)
        .padding(.vertical, 30)
      Text(CoreL10n.kwSendLoveHeadingPasswordchanger)
        .font(.callout)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      Text(CoreL10n.kwSendLoveSubheadingPasswordchanger)
        .font(.caption)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    } buttons: {
      Button(CoreL10n.kwSendLove) {
        viewModel.rateApp()
        dismiss()
      }

      Button(CoreL10n.kwSendFeedback) {
        if MFMailComposeViewController.canSendMail() {
          self.isMailViewPresented = true
        } else {
          self.isMailAlertPresented = true
        }
      }
      Button(CoreL10n.kwSendLoveNothanksbuttonPasswordchanger, role: .cancel) {
        viewModel.cancel()
        dismiss()
      }
    }
    .alertButtonsLayout(.vertical)
    .foregroundStyle(Color.ds.text.neutral.standard)
    .padding(.top)
  }
}

#Preview {
  RateAppView(
    viewModel: .init(
      login: .init("_"),
      sender: .braze,
      userSettings: .mock
    )
  )
}
