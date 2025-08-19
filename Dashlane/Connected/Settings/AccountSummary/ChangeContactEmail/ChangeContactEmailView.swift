import CoreTypes
import DesignSystem
import SwiftUI

struct ChangeContactEmailView: View {

  @StateObject
  var model: ChangeContactEmailViewModel

  @Environment(\.dismiss)
  var dismiss

  @Environment(\.toast)
  var toast

  @State
  var newContactEmail: String = ""

  init(model: @autoclosure @escaping () -> ChangeContactEmailViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    NavigationView {
      List {
        Section(
          footer: Text(L10n.Localizable.changeContactEmailFooter)
        ) {
          DS.TextField(
            L10n.Localizable.changeContactEmailCurrentContactEmail, text: $model.currentContactEmail
          )
          .fieldEditionDisabled()
          DS.TextField(L10n.Localizable.changeContactEmailNewContactEmail, text: $newContactEmail)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onSubmit {
              changeEmail()
            }
        }
      }
      .listStyle(.ds.insetGrouped)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(L10n.Localizable.changeContactEmailCancel) {
            dismiss()
          }
          .foregroundStyle(Color.ds.text.brand.standard)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(L10n.Localizable.changeContactEmailSave) {
            changeEmail()
          }
          .foregroundStyle(Color.ds.text.brand.standard)
          .disabled(newContactEmail.isEmpty)
        }
      }
    }
  }

  func changeEmail() {
    Task {
      do {
        try await model.changeContactEmail(to: newContactEmail)
        dismiss()
      } catch {
        toast(L10n.Localizable.changeContactEmailErrorToast, image: .ds.feedback.fail.outlined)
      }
    }
  }
}

#Preview {
  ChangeContactEmailView(model: .mock)
}
