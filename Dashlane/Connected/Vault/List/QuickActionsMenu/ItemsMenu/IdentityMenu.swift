import SwiftUI
import CorePersonalData
import CoreUserTracking

struct IdentityMenu: View {
    var identity: Identity
    let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

    var body: some View {
        if !identity.firstName.isEmpty {
            CopyMenuButton(L10n.Localizable.copyFirstname) {
                copyAction(.firstName, identity.firstName)
            }
        }

        if !identity.lastName.isEmpty {
            CopyMenuButton(L10n.Localizable.copyLastname) {
                copyAction(.lastName, identity.lastName)
            }
        }

        if !identity.middleName.isEmpty {
            CopyMenuButton(L10n.Localizable.copyMiddlename) {
                copyAction(.middleName, identity.middleName)
            }
        }

        if !identity.defaultLogin.isEmpty {
            CopyMenuButton(L10n.Localizable.copyLogin) {
                copyAction(.login, identity.defaultLogin)
            }
        }
    }
}
