import Foundation
import CorePersonalData

public extension Credential {
    init(_ otpInfo: OTPInfo) {
        let cleanedLogin = otpInfo.configuration.login.removingPercentEncoding ?? otpInfo.configuration.login
        self.init(id: otpInfo.id,
                  login: cleanedLogin,
                  title: otpInfo.configuration.title,
                  password: "",
                  otpURL: otpInfo.configuration.otpURL,
                  url: otpInfo.configuration.issuerURL?.absoluteString,
                  note: otpInfo.recoveryCodes.joined(separator: "\n"))
    }
}
