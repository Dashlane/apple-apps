import Foundation
import SwiftUI
import CorePersonalData
import CoreUserTracking

struct PasskeyMenu: View {
    let passkey: Passkey
    let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

    var body: some View {
        if !passkey.userDisplayName.isEmpty {
            CopyMenuButton(L10n.Localizable.copyLogin) {
                copyAction(.login, passkey.userDisplayName)
            }
        }

        if let url = passkey.relyingPartyId.openableURL {
            OpenWebsiteMenuButton(url: url)
        }
    }
}
