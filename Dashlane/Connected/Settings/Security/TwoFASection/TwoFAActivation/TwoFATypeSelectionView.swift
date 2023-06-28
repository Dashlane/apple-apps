import Foundation
import SwiftUI
import DesignSystem
import UIComponents
import CoreLocalization

enum TFAOption {
    case firstLogin
    case everyLogin

    var title: String {
        switch self {
        case .firstLogin:
            return L10n.Localizable.twofaOptionOtp1Title
        case .everyLogin:
            return L10n.Localizable.twofaOptionOtp2Title
        }
    }
}

struct TwoFATypeSelectionView: View {

    let completion: (TFAOption) -> Void

    @State
    var selectedOption: TFAOption = .firstLogin

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ScrollView {
            mainView
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.Localizable.twofaStepsNavigationTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(action: dismiss.callAsFunction, title: CoreLocalization.L10n.Core.cancel)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(CoreLocalization.L10n.Core.kwNext) {
                    completion(selectedOption)
                }
            }
        }
        .navigationBarStyle(.transparent)
        .reportPageAppearance(.settingsSecurityTwoFactorAuthenticationEnableSecurityLevel)
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Localizable.twofaStepsCaption("1", "3"))
                .foregroundColor(.ds.text.neutral.quiet)
                .font(.callout)
            Text(L10n.Localizable.twofaOptionTitle)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 28,
                              relativeTo: .title)
                    .weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
            Text(L10n.Localizable.twofaOptionSubtitle)
                .foregroundColor(.ds.text.neutral.standard)
                .padding(.top, 8)
                .font(.body)
            selectionView
                .padding(.top, 24)
            Spacer()

        }
        .padding(.all, 24)
    }

    var selectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            optionView(for: .firstLogin)
            Divider()
            optionView(for: .everyLogin)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(.ds.background.alternate)
        .clipShape(Rectangle())
        .cornerRadius(8)

    }

    func optionView(for option: TFAOption) -> some View {
        HStack {
            Text(option.title)
                .foregroundColor(.ds.text.neutral.catchy)
            Spacer()
            if selectedOption == option {
                Image(systemName: "checkmark")
                    .foregroundColor(.ds.text.brand.quiet)
                    .fiberAccessibilityLabel(Text(option.title))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedOption = option
        }
    }
}

struct TwoFATypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TwoFATypeSelectionView { _ in }
        }
    }
}
