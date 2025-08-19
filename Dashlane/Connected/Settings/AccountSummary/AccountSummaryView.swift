import CoreFeature
import CoreLocalization
import CoreSession
import DesignSystem
import SwiftUI
import UserTrackingFoundation

struct AccountSummaryView: View {
  @State
  var showChangeLoginEmailModal = false

  @State
  var showChangeContactEmailModal = false

  @StateObject
  var model: AccountSummaryViewModel

  @FeatureState(.changeLoginEmail)
  var isChangeLoginEmailEnabled: Bool

  @Environment(\.accessControl)
  private var accessControl

  @Environment(\.authenticationMethod)
  private var authenticationMethod: AuthenticationMethod?

  @Environment(\.spacesConfiguration)
  private var spacesConfiguration

  @Environment(\.report)
  var report

  init(model: @autoclosure @escaping () -> AccountSummaryViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    List {
      Section(
        header: Text(L10n.Localizable.accountSummaryLogin).textStyle(.title.supporting.small),
        footer: Text(loginSectionFooter)
      ) {
        DS.DisplayField(
          L10n.Localizable.accountSummaryLoginEmail,
          text: model.session.login.email,
          actions: {
            if canChangeLoginEmail {
              DS.FieldAction.Button(
                L10n.Localizable.accountSummaryEdit,
                image: .ds.action.edit.outlined
              ) {
                accessControl.requestAccess(for: .changeLoginEmail) { success in
                  guard success else { return }

                  showChangeLoginEmailModal = true
                  report?(
                    UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .startEmailChange))
                }
              }
            }
          })
      }

      Section(
        header: Text(L10n.Localizable.accountSummaryAccountVerification).textStyle(
          .title.supporting.small),
        footer: Text(L10n.Localizable.accountSummaryVerificationCodesSent)
      ) {
        DS.DisplayField(
          L10n.Localizable.accountSummaryContactEmail,
          text: model.contactEmail,
          actions: {
            DS.FieldAction.Button(
              L10n.Localizable.accountSummaryEdit,
              image: .ds.action.edit.outlined
            ) {
              accessControl.requestAccess(for: .changeContactEmail) { success in
                guard success else { return }

                showChangeContactEmailModal = true
              }
            }
          })
      }
    }
    .listStyle(.ds.insetGrouped)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(L10n.Localizable.accountSummaryTitle)
    .sheet(isPresented: $showChangeLoginEmailModal) {
      ChangeLoginEmailFlowView(model: model.changeLoginEmailFlowViewModelFactory.make())
    }
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
    .reportPageAppearance(.settingsAccount)
  }

  private var canChangeLoginEmail: Bool {
    isChangeLoginEmailEnabled && authenticationMethod?.isInvisibleMasterPassword == false
      && spacesConfiguration.currentTeam == nil
  }

  private var loginSectionFooter: String {
    canChangeLoginEmail
      ? CoreL10n.ChangeLoginEmail.footer
      : L10n.Localizable.accountSummaryYourLoginEmailCantBeChanged
  }
}

#Preview {
  AccountSummaryView(model: .mock)
}
