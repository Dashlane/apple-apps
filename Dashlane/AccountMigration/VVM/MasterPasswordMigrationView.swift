import Foundation
import SwiftUI
import LoginKit
import UIComponents
import DesignSystem

struct MasterPasswordMigrationView: View {
    let title: String
    let subtitle: String
    let migrateButtonTitle: String
    let cancelButtonTitle: String
    let completion: (MigrationCompletionType) -> Void

    var body: some View {
        VStack {
            Image(asset: FiberAsset.multidevices)
                .accessibilityHidden(true)
            VStack(spacing: 24) {
                Text(title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.ds.text.neutral.quiet)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(.top, 43)

            Spacer()
            VStack(spacing: 8) {

                RoundedButton(migrateButtonTitle, action: { completion(.migrate) })
                    .roundedButtonLayout(.fill)
                Button(action: {completion(.cancel)}, label: {
                    Text(cancelButtonTitle)
                        .foregroundColor(.ds.text.brand.standard)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .contentShape(Rectangle())

                })
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.top, 169)
        .padding(.horizontal, 24)
        .loginAppearance()
    }
}

extension MasterPasswordMigrationView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .hidden()
    }
}

struct MasterPasswordMigrationView_Previews: PreviewProvider {
    static var previews: some View {
        MasterPasswordMigrationView(title: "Create a Master Password for Dashlane",
                                    subtitle: "Your account rights have changed. Create a strong Master Password to log into Dashlane going forward.",
                                    migrateButtonTitle: "Create Master Password",
                                    cancelButtonTitle: "Log out",
                                    completion: {_ in})
    }
}
