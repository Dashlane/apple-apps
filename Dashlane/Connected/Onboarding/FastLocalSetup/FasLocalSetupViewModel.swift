import Foundation
import Combine
import DashlaneAppKit
import SwiftTreats

enum FastLocalSetupMode {
    case biometry(Biometry)
    case rememberMasterPassword
}

protocol FastLocalSetupViewModel: ObservableObject {
    var mode: FastLocalSetupMode { get }
    var isBiometricsOn: Bool { get set }
    var isMasterPasswordResetOn: Bool { get set }
    var shouldShowMasterPasswordReset: Bool { get }
    var biometryNeededPublisher: PassthroughSubject<Void, Never> { get }
    var biometry: Biometry? { get }
    var isRememberMasterPasswordOn: Bool { get set }

    func next()
    func back()
    func markDisplay()
}
