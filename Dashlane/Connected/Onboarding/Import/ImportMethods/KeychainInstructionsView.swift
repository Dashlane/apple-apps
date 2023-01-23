import Foundation
import UIDelight
import SwiftUI
import UIComponents
import DesignSystem

struct KeychainInstructionsView: View {

    enum Completion {
        case goToSettings
        case cancel
    }

    let completion: ((Completion) -> Void)

    var body: some View {
        ScrollViewIfNeeded {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.Localizable.keychainInstructionsTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(DashlaneFont.custom(26, .bold).font)
                        .padding(.top, 80)

                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(Color(asset: FiberAsset.grey01))
                        Text(L10n.Localizable.keychainInstructionsWebsitesAndAppPasswords)
                        Spacer()
                        Image(systemName: "xmark.circle.fill").foregroundColor(Color(asset: FiberAsset.grey01))
                    }
                    .padding(10)
                    .background(Color(asset: FiberAsset.grey06))
                    .cornerRadius(10)
                    .padding(.top, 57)

                    Text(L10n.Localizable.keychainInstructionsHowToFindSearchBar)
                        .font(.footnote)
                        .foregroundColor(Color(asset: FiberAsset.neutralText))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .padding(.top, 13)
                }
                .fiberAccessibilityElement(children: .combine)

                Text(L10n.Localizable.keychainInstructionsChoosePasswordToCopy)
                    .font(.body)
                    .bold()
                    .fixedSize(horizontal: false, vertical: false)
                    .padding(.top, 37)

                Spacer()
                RoundedButton(L10n.Localizable.keychainInstructionsCTA, action: { self.completion(.goToSettings) })
                    .roundedButtonLayout(.fill)
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: 400)
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(L10n.Localizable.keychainInstructionsCancel) {
                    completion(.cancel)
                }
            }
        }
    }
}

extension KeychainInstructionsView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .transparent(tintColor: FiberAsset.dashGreenCopy.color, statusBarStyle: .default)
    }
}

struct KeychainInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            KeychainInstructionsView { result in
                switch result {
                case .cancel:
                    print("Canceled")
                case .goToSettings:
                    print("Go to Settings")
                }
            }
        }
    }
}
