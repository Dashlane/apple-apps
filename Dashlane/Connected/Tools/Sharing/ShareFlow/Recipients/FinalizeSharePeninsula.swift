import CoreTypes
import DesignSystem
import SwiftUI

struct FinalizeSharePeninsula: View {
  @Binding
  var permission: SharingPermission
  var showPermissionLevelSelector: Bool
  let action: () -> Void

  var body: some View {
    VStack {
      Divider()
        .padding(.horizontal)

      if showPermissionLevelSelector {
        HStack {
          Text(L10n.Localizable.kwSharePermissionLabel)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .accessibilityHidden(true)

          Picker(L10n.Localizable.kwSharePermissionLabel, selection: $permission) {
            Text(L10n.Localizable.kwSharingAdmin)
              .tag(SharingPermission.admin)
            Text(L10n.Localizable.kwSharingMember)
              .tag(SharingPermission.limited)
          }.frame(maxWidth: .infinity, alignment: .trailing).pickerStyle(.menu)
        }
        .padding(.leading, 23)
        .padding(.trailing, 11)
      }

      Button(L10n.Localizable.kwShare, action: action)
        .buttonStyle(.designSystem(.titleOnly))
        .padding(.horizontal)
    }
    .padding(.bottom, 30)

  }
}

struct FinalizeSharePeninsula_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      FinalizeSharePeninsula(permission: .constant(.limited), showPermissionLevelSelector: true) {

      }
    }
  }
}
