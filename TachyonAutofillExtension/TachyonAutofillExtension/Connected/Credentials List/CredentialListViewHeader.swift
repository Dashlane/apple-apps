import NotificationKit
import SwiftUI

struct CredentialListViewHeader: View {

  enum Mode {
    case addCredential(action: () -> Void)
    case cannotAddCredential(action: () -> Void)
  }

  let mode: Mode

  var body: some View {
    switch mode {
    case let .addCredential(action):
      addCredentialHeader(action: action)
    case let .cannotAddCredential(action):
      PasswordLimitReachedAnnouncementView(action: action)
    }
  }

  private func addCredentialHeader(action: @escaping () -> Void) -> some View {
    Button(
      action: {
        action()
      },
      label: {
        AddCredentialRowView()
      })
  }
}

private struct AddCredentialRowView: View {

  var body: some View {
    HStack(spacing: 16) {
      main
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .listRowBackground(Color.ds.background.default)
  }

  private var main: some View {
    HStack(spacing: 16) {
      Image(asset: FiberAsset.addNewPassword)
      Text(L10n.Localizable.addNewPassword)
        .foregroundColor(.ds.text.brand.standard)
    }
    .padding(.vertical, 5)
  }
}

#Preview {
  Group {
    CredentialListViewHeader(mode: .addCredential(action: {}))
    CredentialListViewHeader(mode: .cannotAddCredential(action: {}))
  }
}
