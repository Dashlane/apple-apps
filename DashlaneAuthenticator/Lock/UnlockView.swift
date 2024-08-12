import CoreSession
import Foundation
import LoginKit
import SwiftUI
import UIDelight

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
        .toolbar(.hidden, for: .navigationBar)
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
      BiometryUnlockView(
        model: model.makeBiometryUnlockViewModel(
          biometryType: type,
          completion: { result in
            DispatchQueue.main.async {
              dismiss()
              model.completion(result)
            }
          }))

    case let .pincode(lock):
      PinUnlockView(
        model: model.makePinUnlockViewModel(
          pin: lock.code, pinCodeAttempts: lock.attempts, masterKey: lock.masterKey,
          completion: { result in
            DispatchQueue.main.async {
              dismiss()
              model.completion(result)
            }
          }))
    case let .biometryAndPincode(lock, biometry):
      BiometryAndPinUnlockView(
        model: model.makeBiometryAndPinUnlockViewModel(
          pin: lock.code,
          pinCodeAttempts: lock.attempts,
          masterKey: lock.masterKey,
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
