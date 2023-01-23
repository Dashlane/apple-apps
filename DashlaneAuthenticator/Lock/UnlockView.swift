import Foundation
import SwiftUI
import DashlaneAppKit
import CoreSession
import UIDelight
import LoginKit

struct UnlockView: View {
    @StateObject
    var model: UnlockViewModel

    @Environment(\.dismiss)
    private var dismiss
    
    init(model: @autoclosure @escaping () -> UnlockViewModel) {
        _model = .init(wrappedValue: model())
    }
    
    var body: some View {
        NavigationView {
            mainView
                .backgroundColorIgnoringSafeArea(.ds.background.alternate)
                .animation(.easeInOut, value: model.showOnboarding)
                .hiddenNavigationTitle()
        }.navigationBarDefaultStyle(.transparent)
    }

    @ViewBuilder
    private var mainView: some View {
        if model.show2faOnboarding {
            Dashlane2FAOnboardingView(completion: model.didFinish2FAOnboarding)
        } else if model.showOnboarding == true {
            PairedModeOnboardingView(mode: model.mode, completion: model.didFinishOnboarding)
        } else {
            lockView
        }
    }
    
    @ViewBuilder
    private var lockView: some View {
        switch model.mode {
        case let .biometry(type):
            BiometryUnlockView(model: model.makeBiometryUnlockViewModel(biometryType: type, completion: { result in
                DispatchQueue.main.async {
                    dismiss()
                    model.completion(result)
                }
            }))
            
        case let .pincode(pin, attempts, masterKey):
            PinUnlockView(model: model.makePinUnlockViewModel(pin: pin, pinCodeAttempts: attempts, masterKey: masterKey, completion: { result in
                DispatchQueue.main.async {
                    dismiss()
                    model.completion(result)
                }
            }))
        case let .biometryAndPincode(pin, attempts, masterKey, biometry):
            BiometryAndPinUnlockView(model: model.makeBiometryAndPinUnlockViewModel(pin: pin,
                                                                              pinCodeAttempts: attempts,
                                                                              masterKey: masterKey,
                                                                              biometryType: biometry,
                                                                              completion: { result in
                DispatchQueue.main.async {
                    dismiss()
                    model.completion(result)
                }
            }))
        }
    }
}
