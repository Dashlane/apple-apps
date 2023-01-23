import Foundation
import SwiftUI
import UIComponents
import DashTypes
import DesignSystem

enum MigrationCompletionType {
    case cancel
    case migrate
}

struct SSOMigrationView: View {
    let completion: (MigrationCompletionType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 21) {
            Image(asset: FiberAsset.ssoOutlined)
            VStack(alignment: .leading, spacing: 24) {
                Text(L10n.Localizable.ssoMigrationTitle).font(.headline)
                Group {
                    Text(L10n.Localizable.ssoMigrationMessage)
                    Text(L10n.Localizable.ssoMigrationMessage2)
                    Button(action: {
                        UIApplication.shared.open(DashlaneURLFactory.ssoEnabled)
                    }, label: {
                        Text(L10n.Localizable.ssoMigrationAboutTitle)
                            .underline()

                    })
                }
                .font(.caption)
                .foregroundColor(Color(asset: FiberAsset.neutralText))

                Infobox(title: L10n.Localizable.ssoMigrationNote)

                RoundedButton(L10n.Localizable.activateSSOButtonTitle) {
                    completion(.migrate)
                }
                .roundedButtonLayout(.fill)
                .padding(.top, 17)

            }
        }
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBarButton(action: { self.completion(.cancel) }, title: L10n.Localizable.cancel)
            }
        }
    }
}

extension SSOMigrationView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .transparent()
    }
}

struct SSOMigrationView_Previews: PreviewProvider {
    static var previews: some View {
        SSOMigrationView { _ in}
    }
}
