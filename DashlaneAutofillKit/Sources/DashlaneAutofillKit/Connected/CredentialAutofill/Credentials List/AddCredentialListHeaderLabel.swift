import DesignSystem
import SwiftUI

struct AddCredentialListHeaderLabel: View {
  var body: some View {
    HStack(spacing: 16) {
      main
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .listRowBackground(Color.ds.background.default)
  }

  private var main: some View {
    HStack(spacing: 16) {
      Thumbnail.icon(.ds.action.add.outlined)

      Text(L10n.Localizable.addNewPassword)
    }
    .padding(.vertical, 5)
    .foregroundStyle(Color.ds.text.brand.standard)
  }
}

#Preview {
  AddCredentialListHeaderLabel()
}
