import CoreLocalization
import DesignSystem
import SwiftUI

struct AccountSummaryView: View {

  @State
  var showChangeContactEmailModal = false

  @StateObject
  var model: AccountSummaryViewModel

  init(model: @autoclosure @escaping () -> AccountSummaryViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    List {
      Section(
        header: Text(L10n.Localizable.accountSummaryLogin).textStyle(.title.supporting.small),
        footer: Text(L10n.Localizable.accountSummaryYourLoginEmailCantBeChanged)
      ) {
        DS.TextField(
          L10n.Localizable.accountSummaryLoginEmail, text: .constant(model.session.login.email)
        )
        .editionDisabled(appearance: .discrete)
        .fieldAppearance(.grouped)
      }

      Section(
        header: Text(L10n.Localizable.accountSummaryAccountVerification).textStyle(
          .title.supporting.small),
        footer: Text(L10n.Localizable.accountSummaryVerificationCodesSent)
      ) {
        DS.TextField(
          L10n.Localizable.accountSummaryContactEmail,
          placeholder: L10n.Localizable.accountSummaryContactEmail,
          text: $model.contactEmail,
          actions: {
            DS.FieldAction.Button(
              L10n.Localizable.accountSummaryEdit,
              image: .ds.action.edit.outlined
            ) {
              showChangeContactEmailModal = true
            }
          }
        )
        .editionDisabled(appearance: .discrete)
        .fieldAppearance(.grouped)
      }
    }
    .listAppearance(.insetGrouped)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(L10n.Localizable.accountSummaryTitle)
    .sheet(isPresented: $showChangeContactEmailModal) {
      ChangeContactEmailView(
        model: model.changeContactEmailViewModelFactory.make(
          currentContactEmail: model.contactEmail,
          onSaveAction: { Task { await model.fetchContactEmail() } })
      )
      .toasterOn()
    }
    .task {
      await model.fetchContactEmail()
    }
  }
}

#Preview {
  AccountSummaryView(model: .mock)
}
