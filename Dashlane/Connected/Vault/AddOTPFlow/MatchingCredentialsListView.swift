import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

struct MatchingCredentialsListView: View {

  @StateObject
  var viewModel: MatchingCredentialListViewModel

  init(viewModel: MatchingCredentialListViewModel) {
    self._viewModel = .init(wrappedValue: viewModel)
  }

  var body: some View {
    ScrollView {
      Spacer(minLength: 40)
      VStack(spacing: 24) {
        explanations
        VStack(spacing: 16) {
          ForEach(viewModel.matchingCredentials, content: row)
        }
        createCredentialButton
      }
      .padding(.horizontal, 24)

    }
    .navigationBarTitleDisplayMode(.inline)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  private var explanations: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(
          L10n.Localizable.pwmMatchingCredentialsListMultipleLoginsAvailable(
            viewModel.matchingCredentials.count, viewModel.issuer)
        )
        .font(.title.bold())
        .multilineTextAlignment(.leading)
        .foregroundColor(.ds.text.neutral.catchy)
        Spacer()
      }
      Text(L10n.Localizable.pwmMatchingCredentialsListDescription)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)
    }
  }

  @ViewBuilder
  private func row(for credential: Credential) -> some View {
    HStack(spacing: 16) {
      VaultItemRow(
        item: credential,
        userSpace: nil,
        vaultIconViewModelFactory: viewModel.vaultItemIconViewModelFactory
      )
      .vaultItemRowHideSharing()

      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(.ds.text.neutral.catchy)
        .fiberAccessibilityHidden(true)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .onTapWithFeedback { viewModel.link(to: credential) }
    .cornerRadius(4)
  }

  private var createCredentialButton: some View {
    Button(
      action: {
        viewModel.createCredential()
      },
      label: {
        Text(L10n.Localizable.addNewPassword)
          .font(.body.weight(.medium))
          .foregroundColor(.ds.text.brand.standard)
      })
  }
}

struct MatchingCredentialsList_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      MatchingCredentialsListView(viewModel: .mock())
    }
  }
}
