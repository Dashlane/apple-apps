import CoreLocalization
import DashTypes
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
      .modifier(AlertStyle())
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
          Button(L10n.Core.kwButtonOk) {
            dismiss()
          }
        },
        message: {
          Text(L10n.Core.kwSharingNoEmailAccount)
        }
      )
      .onAppear {
        viewModel.markRateAppHasBeenShown()
      }
  }

  private var mainView: some View {
    VStack(spacing: 10) {
      Image(asset: Asset.sendLove)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(.ds.text.brand.standard)
        .padding(.horizontal, 70.0)
        .padding(.vertical, 30)
      Text(L10n.Core.kwSendLoveHeadingPasswordchanger)
        .font(.callout)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      Text(L10n.Core.kwSendLoveSubheadingPasswordchanger)
        .font(.caption)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      VStack(spacing: 0) {
        Divider()
        Button(
          L10n.Core.kwSendLove,
          action: {
            viewModel.rateApp()
            dismiss()
          }
        )
        .foregroundColor(.ds.text.brand.standard)
        Divider()
        Button(
          L10n.Core.kwSendFeedback,
          action: {
            if MFMailComposeViewController.canSendMail() {
              self.isMailViewPresented = true
            } else {
              self.isMailAlertPresented = true
            }
          })
        Divider()
        Button(
          L10n.Core.kwSendLoveNothanksbuttonPasswordchanger,
          action: {
            viewModel.cancel()
            dismiss()
          })
      }

    }
    .buttonStyle(RateAppButtonStyle())
    .foregroundColor(.ds.text.neutral.standard)
    .padding(.top)
  }
}

private struct RateAppButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.callout)
      .padding(.all, 15)
      .frame(maxWidth: .infinity)
      .contentShape(Rectangle())
  }
}

struct RateAppView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      RateAppView(viewModel: .init(login: .init("_"), sender: .braze, userSettings: .mock))
    }
  }
}
