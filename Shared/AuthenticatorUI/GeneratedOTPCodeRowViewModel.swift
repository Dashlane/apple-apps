import Foundation
import SwiftUI
import TOTPGenerator
import AuthenticatorKit

class GeneratedOTPCodeRowViewModel: ObservableObject {

    var token: OTPInfo

    @Published
    var code: String

        var separatedCode: String {
        code.separated()
    }
    
        var accessibilityCode: String {
        code.separated(by: " ", stride: 1)
    }

    enum Mode {
        case totp(progress: CGFloat, refreshPeriod: TimeInterval)
        case hotp(counter: UInt64)
    }

    @Published
    var currentMode: Mode

    let databaseService: AuthenticatorDatabaseServiceProtocol

    init(token: OTPInfo, databaseService: AuthenticatorDatabaseServiceProtocol) {
        self.token = token
        self.databaseService = databaseService
        switch token.configuration.type {
        case let .totp(period):
            let remaining = TOTPGenerator.timeRemaining(in: period)
            self.currentMode = .totp(progress: CGFloat((period - remaining) / period), refreshPeriod: period)
            code = TOTPGenerator.generate(with: token, at: Date())
        case let .hotp(counter):
            self.currentMode = .hotp(counter: counter)
            self.code = TOTPGenerator.generate(with: token)
        }
    }

        func update(period: TimeInterval) {
        self.code = TOTPGenerator.generate(with: token)
        let remainingTime = TOTPGenerator.timeRemaining(in: period)
        let progress = CGFloat((period - remainingTime) / period)
        self.currentMode = .totp(progress: progress, refreshPeriod: period)
    }

        func increaseHOTPCounter() {
        let newToken = self.token.increasingCounter()
        self.token = newToken

        guard case let .hotp(newCounter) = self.token.configuration.type else {
            assertionFailure("Should have HOTP here")
            return
        }
        self.currentMode = .hotp(counter: newCounter)

        self.code = TOTPGenerator.generate(with: token)
        try? databaseService.update(newToken)
    }

}

extension OTPInfo {

    func increasingCounter(by valueToAdd: UInt64 = 1) -> OTPInfo {

        guard case let .hotp(counter) = self.configuration.type else {
            assertionFailure("Cannot increase counter of TOTP")
            return self
        }
        let newCounter = counter + valueToAdd
        let url = self.configuration.otpURL
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var items = components?.queryItems?.filter {
            $0.name != "counter"
        }

        items?.append(URLQueryItem(name: "counter", value: String(newCounter)))
        components?.queryItems = items

        guard let url = components?.url,
              let newConfiguration = try? OTPConfiguration(otpURL: url, defaultTitle: configuration.title, defaultLogin: configuration.login, defaultIssuer: configuration.issuer) else {
            assertionFailure("Could not build new URL")
            return self
        }
        return OTPInfo(id: self.id,
                       configuration: newConfiguration,
                       isFavorite: isFavorite,
                       recoveryCodes: recoveryCodes)
    }
}

extension TOTPGenerator {
    static func generate(with token: OTPInfo,
                         at date: Date = Date()) -> String {

        var counter: UInt64?
        if case let .hotp(tokenCounter) = token.configuration.type {
            counter = tokenCounter
        }

        return TOTPGenerator.generate(with: token.configuration.type,
                                      for: date,
                                      digits: token.configuration.digits,
                                      algorithm: token.configuration.algorithm,
                                      secret: token.configuration.secret,
                                      currentCounter: counter)
    }
}
