import SwiftUI
import UIDelight

struct ChangeLoginEmailFlowView: View {
  @StateObject
  var model: ChangeLoginEmailFlowViewModel

  @State
  private var newLoginEmail: String = ""

  @State
  private var verificationCode: String = ""

  @Environment(\.dismiss)
  private var dismiss

  public init(model: @autoclosure @escaping () -> ChangeLoginEmailFlowViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    StepBasedNavigationView(steps: $model.steps) { step in
      switch step {
      case .newEmail:
        ChangeLoginEmailNewEmailView(
          currentLoginEmail: model.currentLoginEmail,
          newLoginEmail: $newLoginEmail,
          errorMessage: model.errorMessage
        ) { completion in
          switch completion {
          case .requestChange(let newLoginEmail):
            Task {
              await model.requestLognEmailChange(newLoginEmail: newLoginEmail)
            }
          case .cancel:
            Task {
              await model.cancel()
            }
          }
        }
        .onChange(of: newLoginEmail) {
          model.errorMessage = nil
        }
      case .verificationCode:
        ChangeLoginEmailVerificationCodeView(
          newLoginEmail: newLoginEmail,
          verificationCode: $verificationCode,
          errorMessage: model.errorMessage,
          inProgress: model.isPerformingEvent
        ) { completion in
          switch completion {
          case .confirmVerificationCode(let verificationCode):
            Task {
              await model.validateVerificationCode(verificationCode: verificationCode)
            }
          case .resendVerificationCode:
            Task {
              await model.resendVerificationCode()
            }
          case .back:
            Task {
              newLoginEmail = ""
              verificationCode = ""
              await model.reset()
            }
          }
        }
        .onChange(of: verificationCode) {
          model.errorMessage = nil
        }
      case let .success(newSession):
        ChangeLoginEmailSuccessView {
          model.relogin(newSession: newSession)
        }
      case .failure:
        ChangeLoginEmailFailureView { completion in
          switch completion {
          case .tryAgain:
            Task {
              newLoginEmail = ""
              verificationCode = ""
              await model.reset()
            }
          case .cancel:
            Task {
              await model.cancel()
            }
          }
        }
      }
    }
    .onReceive(model.dismissPublisher) { _ in
      dismiss()
    }
  }
}

#Preview {
  ChangeLoginEmailFlowView(model: .mock)
}
