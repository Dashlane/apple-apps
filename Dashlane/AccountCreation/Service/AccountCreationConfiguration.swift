import Foundation
import DashTypes
import DashlaneAPI

struct AccountCreationConfiguration {
    struct LocalConfiguration {
        var isBiometricAuthenticationEnabled: Bool = false
        var isMasterPasswordResetEnabled: Bool = false
        var isRememberMasterPasswordEnabled: Bool = false
        var pincode: String?
    }

    let email: DashTypes.Email
    let password: String
    let accountType: AccountAccountType

    var local = LocalConfiguration()
    var hasUserAcceptedEmailMarketing: Bool = false
}
