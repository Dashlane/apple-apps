import Foundation
import SwiftUI
import CoreLocalization

struct RecoveryCodesConfirmationView: View {

    @Binding
    var recoveryCodes: [String]

    @State
    var itemToDelete: String?

    let save: () -> Void

    let cancel: () -> Void

    var body: some View {
        NavigationView {
            mainView
                .alert(item: $itemToDelete) { item in
                    Alert(title: Text(""),
                          message: Text(L10n.Localizable.deletionAlertTitle(item)),
                          primaryButton: .destructive(Text(L10n.Localizable.deleteButtonTitle), action: {
                            recoveryCodes.removeAll {$0 == item}
                          }),
                          secondaryButton: .cancel())
                }
        }
    }

    var mainView: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(Array(recoveryCodes.enumerated()), id: \.element) { index, code in
                    RecoveryCodeRowView(
                        code: code,
                        index: index,
                        action: { itemToDelete = code },
                        content: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    )
                }
            }
            .padding(.top, 20)

        }
        .padding(.horizontal, 16)
        .navigationTitle(L10n.Localizable.recoveryCodesNavigationBarTitle, displayMode: .large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(CoreLocalization.L10n.Core.cancelButtonTitle, action: cancel)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(L10n.Localizable.saveButtonTitle, action: save)
            }
        }
    }
}

struct AddTitleView_preview: PreviewProvider {

    static var previews: some View {
        RecoveryCodesConfirmationView(recoveryCodes: .constant(OTPInfo.mockWithRecoveryCodes.recoveryCodes), save: {}, cancel: {})

    }
}
