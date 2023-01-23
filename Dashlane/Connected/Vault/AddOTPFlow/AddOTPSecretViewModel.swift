import Foundation
import CorePersonalData
import TOTPGenerator

class AddOTPSecretViewModel: ObservableObject {

    let credential: Credential
    let completion: (Result<OTPConfiguration, Error>) -> Void

    @Published
    var otpSecretKey: String = ""

    init(credential: Credential,
         completion: @escaping (Result<OTPConfiguration, Error>) -> Void) {
        self.credential = credential
        self.completion = completion
    }

    func validate() {
        do {
            let otpSecretKey = otpSecretKey.removeWhitespacesCharacters()
            let otpURL = try URL.makeOTPURL(title: credential.title,
                                            login: credential.login,
                                            issuer: credential.title,
                                            secret: otpSecretKey)
            let otpConfiguration = try OTPConfiguration(otpURL: otpURL, supportDashlane2FA: false)
            completion(.success(otpConfiguration))
        } catch {
            completion(.failure(error))
        }
    }
}
