import DashTypes
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct DownloadDashlaneView: View {

  @Environment(\.dismiss)
  private var dismiss

  let cardContent = [
    L10n.Localizable.backupYourAccountsCardStepDownload,
    L10n.Localizable.backupYourAccountsCardStepCreateAccount,
    L10n.Localizable.backupYourAccountsCardStepBenefit,
  ]

  @StateObject
  var viewModel: DownloadDashlaneViewModel

  init(model: DownloadDashlaneViewModel) {
    _viewModel = .init(wrappedValue: model)
  }

  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        ScrollView {
          VStack(alignment: .leading, spacing: 48) {
            header
              .padding(.trailing)
            InstructionsCardView(cardContent: cardContent)
          }
        }
        Spacer()
        buttons
          .padding(.bottom)
      }
      .toolbar(content: {
        ToolbarItem(placement: .navigationBarTrailing) {
          CloseButton(action: dismiss.callAsFunction)
        }

      })
      .padding(.horizontal, 24)
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }
  }

  var header: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(L10n.Localizable.backupYourAccountsTitle)
        .font(.authenticator(.largeTitle))
        .foregroundColor(.ds.text.neutral.catchy)
      Text(L10n.Localizable.backupYourAccountsDescription)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)
      Link(
        title: L10n.Localizable.backupYourAccountsLearnMoreCta,
        supportURL: .whatIsDashlane)
    }
  }

  var buttons: some View {
    VStack(spacing: 24) {
      Button(action: viewModel.openAppStoreView) {
        Text(L10n.Localizable.backupYourAccountsDownloadAppCta)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .buttonDisplayProgressIndicator(viewModel.isLoading)
    }
  }
}

struct DownloadDashlaneView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(dynamicTypePreview: true) {
      DownloadDashlaneView(
        model: DownloadDashlaneViewModel(activityReporter: .mock, showAppStorePage: { _ in }))
    }
  }
}
