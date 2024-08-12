import CorePersonalData
import SwiftUI
import UIDelight

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
          ForEach(viewModel.matchingCredentials, id: \.id) { credential in
            CredentialRowView(model: viewModel.makeCredentialRowViewModel(credential: credential)) {
              viewModel.link(to: credential)
            }
          }
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
          L10n.Localizable.matchingCredentialsListMultipleLoginsAvailable(
            viewModel.matchingCredentials.count, viewModel.issuer)
        )
        .font(.authenticator(.mediumTitle))
        .multilineTextAlignment(.leading)
        .foregroundColor(.ds.text.neutral.catchy)
        Spacer()
      }
      Text(L10n.Localizable.matchingCredentialsListDescription)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)
    }
  }

  private var createCredentialButton: some View {
    Button(
      action: {
        viewModel.createCredential()
      },
      label: {
        Text(L10n.Localizable.matchingCredentialsListCreateNew)
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
