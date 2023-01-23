import SwiftUI

struct RecoveryDetailView: View {
    @Binding
    var recoveryCodes: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(Array(recoveryCodes.enumerated()), id: \.element) { index, code in
                    RecoveryCodeRowView(code: code, index: index, action: { UIPasteboard.general.string = code }) {
                        Image(asset: AuthenticatorAsset.copyIcon)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 16)
        .navigationTitle(L10n.Localizable.recoveryCodesNavigationBarTitle)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct RecoveryDetailView_preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryDetailView(recoveryCodes: .constant(OTPInfo.mockWithRecoveryCodes.recoveryCodes))
        }
    }
}

extension String: Identifiable {
    public var id: String {
        return UUID().uuidString
    }
}
