import CoreLocalization
import DesignSystem
import SwiftUI
import UserTrackingFoundation

struct ChangeLoginEmailNewEmailView: View {
  typealias L10n = CoreL10n.ChangeLoginEmail

  enum Completion {
    case requestChange(newLoginEmail: String)
    case cancel
  }

  @FocusState
  private var isFocused: Bool

  let currentLoginEmail: String

  @Binding
  var newLoginEmail: String

  var errorMessage: String?

  let completion: (Completion) -> Void

  @Environment(\.report)
  var report

  var body: some View {
    List {
      Section(
        footer: Text(L10n.footer)
      ) {
        DS.TextField(
          L10n.currentLoginEmail,
          text: .constant(currentLoginEmail)
        )
        .fieldEditionDisabled()

        DS.TextField(
          L10n.newLoginEmail,
          placeholder: L10n.newLoginEmail,
          text: $newLoginEmail,
          actions: {
            if !newLoginEmail.isEmpty {
              DS.FieldAction.ClearContent(text: $newLoginEmail)
            }
          },
          feedback: {
            if let errorMessage {
              FieldTextualFeedback(errorMessage)
            }
          }
        )
        .focused($isFocused)
        .style(mood: errorMessage != nil ? .danger : .neutral)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .onSubmit {
          completion(.requestChange(newLoginEmail: newLoginEmail))
          report?(UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .submitEmailChange))
        }
      }
    }
    .listStyle(.ds.insetGrouped)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(L10n.cancel, role: .cancel) {
          completion(.cancel)
        }
        .foregroundStyle(Color.ds.text.brand.standard)
      }

      ToolbarItem(placement: .topBarTrailing) {
        Button(L10n.next) {
          completion(.requestChange(newLoginEmail: newLoginEmail))
          report?(UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .submitEmailChange))
        }
        .foregroundStyle(Color.ds.text.brand.standard)
        .disabled(newLoginEmail.isEmpty)
      }
    }
    .onAppear {
      isFocused = true
    }
    .navigationTitle(L10n.navigationTitle)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
  }
}

#Preview {
  ChangeLoginEmailNewEmailView(
    currentLoginEmail: "_",
    newLoginEmail: .constant("_"),
    errorMessage: nil,
    completion: { _ in }
  )
}
