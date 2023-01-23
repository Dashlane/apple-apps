import Foundation

class RecoveryCodesConfirmationViewModel {

    let token: OTPInfo
    let otpTokenService: AuthenticatorDatabaseService
    
    init(token: OTPInfo, otpTokenService: AuthenticatorDatabaseService) {
        self.token = token
        self.otpTokenService = otpTokenService
    }
    
    func save() {
        do {
            try otpTokenService.add([token])
        } catch {
                    }
    }
    
    func skip() {
        var tokenToSave = token
        tokenToSave.recoveryCodes = []
        do {
            try otpTokenService.add([tokenToSave])
        } catch {
                    }
    }
}
