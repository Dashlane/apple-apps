import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight
import UserTrackingFoundation

struct ChangeLoginEmailVerificationCodeView: View {
  typealias L10n = CoreL10n.ChangeLoginEmail

  enum Completion {
    case confirmVerificationCode(verificationCode: String)
    case resendVerificationCode
    case back
  }

  let newLoginEmail: String

  @Binding
  var verificationCode: String

  var errorMessage: String?

  @State
  var inProgress: Bool

  @State
  private var showTroubleWithCodePopup: Bool = false

  @FocusState
  private var isFocused: Bool

  let completion: (Completion) -> Void

  @Environment(\.report)
  var report

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(L10n.pinScreenTitle)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)

      PartlyModifiedText(
        text: L10n.pinScreenMessage(newLoginEmail),
        toBeModified: newLoginEmail,
        toBeModifiedModifier: { $0.bold() }
      )
      .textStyle(.body.standard.regular)
      .foregroundStyle(Color.ds.text.neutral.standard)
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)

      DS.TextField(
        L10n.verificationCode,
        placeholder: L10n.verificationCode,
        text: $verificationCode,
        actions: {
          if !verificationCode.isEmpty {
            DS.FieldAction.ClearContent(text: $verificationCode)
          }
        },
        feedback: {
          if let errorMessage {
            FieldTextualFeedback(errorMessage)
          }
        }
      )
      .style(mood: errorMessage != nil ? .danger : .neutral)
      .keyboardType(.numberPad)
      .focused($isFocused)
      .onSubmit {
        completion(.confirmVerificationCode(verificationCode: verificationCode))
        report?(UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .verifyToken))
      }

      Spacer()

      VStack {
        Button(L10n.next) {
          completion(.confirmVerificationCode(verificationCode: verificationCode))
          report?(UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .verifyToken))
        }
        .buttonStyle(.designSystem(.titleOnly))
        .disabled(!isValidVerificationCode)
        .buttonDisplayProgressIndicator(inProgress)

        Button(L10n.troubleWithCode) {
          showTroubleWithCodePopup = true
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(intensity: .supershy)
        .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding()
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .onAppear {
      isFocused = true
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(
          action: {
            completion(.back)
          },
          label: {
            HStack {
              Image(systemName: "chevron.backward")
                .bold()
              Text(L10n.back)
            }
          })
      }
    }
    .alert(
      L10n.troubleWithCodeAlertTitle,
      isPresented: $showTroubleWithCodePopup,
      actions: {
        Button(L10n.cancel, role: .cancel) {}

        Button(L10n.troubleWithCodeAlertCta) {
          completion(.resendVerificationCode)
        }
      },
      message: {
        Text(L10n.troubleWithCodeAlertMessage)
      }
    )
    .navigationTitle(L10n.navigationTitle)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
  }

  private var isValidVerificationCode: Bool {
    verificationCode.count == 6
  }
}

#Preview {
  ChangeLoginEmailVerificationCodeView(
    newLoginEmail: "_",
    verificationCode: .constant("123456"),
    errorMessage: nil,
    inProgress: false,
    completion: { _ in }
  )
}
