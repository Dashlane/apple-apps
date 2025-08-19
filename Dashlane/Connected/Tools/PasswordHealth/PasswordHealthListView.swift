import CorePersonalData
import SwiftUI
import VaultKit

struct PasswordHealthListView: View {

  @ObservedObject
  var viewModel: PasswordHealthListViewModel
  let action: (PasswordHealthView.Action) -> Void

  init(
    viewModel: PasswordHealthListViewModel,
    action: @escaping (PasswordHealthView.Action) -> Void
  ) {
    self.viewModel = viewModel
    self.action = action
  }

  var body: some View {
    if !viewModel.credentials.isEmpty {
      if viewModel.showSectionHeader {
        Section(header: header) {
          rows
        }
      } else {
        rows
      }
    }
  }

  private var rows: some View {
    VStack(spacing: 0) {
      ForEach(viewModel.credentials, id: \.id) { credential in
        viewModel.rowViewFactory.make(
          item: credential,
          exclude: { viewModel.exclude(credential: credential) },
          replace: { viewModel.replace(credential: credential) },
          detail: detail(for:)
        )
        .padding(.horizontal, 16)

        if viewModel.credentials.last != credential {
          Divider()
            .padding(.leading, 16)
        }
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(Color.ds.container.agnostic.neutral.supershy)
    )
  }

  private var header: some View {
    HStack {
      Text(viewModel.kind.title)
        .font(.title3.bold())
        .foregroundStyle(Color.ds.text.neutral.standard)

      Spacer()

      if case .shown(let credentialsCount) = viewModel.showAllButtonState {
        Button(L10n.Localizable.passwordHealthSeeAll(credentialsCount)) {
          action(.detailedList(viewModel.kind))
        }
        .font(.body)
        .foregroundStyle(Color.ds.text.brand.standard)
      }
    }
    .padding(.top, 32)
    .padding(.bottom, 12)
  }

  private func detail(for credential: Credential) {
    action(.credentialDetail(credential))
  }
}

struct PasswordHealthListView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordHealthListView(viewModel: .mock) { _ in }
  }
}
