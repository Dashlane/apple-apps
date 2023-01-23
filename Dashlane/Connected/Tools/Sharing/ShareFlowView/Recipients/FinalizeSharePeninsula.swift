import SwiftUI
import DashTypes
import DesignSystem

struct FinalizeSharePeninsula: View {
    @Binding
    var permission: SharingPermission
    let action: () -> Void

    var body: some View {
        VStack {
            Divider()
                .padding(.horizontal)

            HStack {
                Text(L10n.Localizable.kwSharePermissionLabel)
                    .foregroundColor(Color.ds.text.neutral.standard)
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

            RoundedButton(L10n.Localizable.kwShare, action: action)
                .roundedButtonLayout(.fill)
                .padding(.horizontal)
        }
        .padding(.bottom, 30)

    }
}

struct FinalizeSharePeninsula_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            FinalizeSharePeninsula(permission: .constant(.limited)) {

            }
        }
    }
}
