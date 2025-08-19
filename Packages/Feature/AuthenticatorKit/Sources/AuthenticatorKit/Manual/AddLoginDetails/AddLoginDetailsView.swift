import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight

public struct AddLoginDetailsView: View {

  @StateObject
  var viewModel: AddLoginDetailsViewModel

  public init(viewModel: @autoclosure @escaping () -> AddLoginDetailsViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  @FocusState
  var isWebsiteEditing: Bool
  @FocusState
  var isLoginEditing: Bool
  @FocusState
  var isSecretKeyEditing: Bool

  public var body: some View {
    ScrollView {
      VStack(spacing: 12) {
        userInput(
          header: CoreL10n.addLoginDetailsWebsiteOrApp,
          placeholder: CoreL10n.addLoginDetailsWebsiteOrApp,
          value: $viewModel.newLogin.website,
          focused: $isWebsiteEditing
        ) {
          self.isLoginEditing = true
        }
        .submitLabel(.next)

        userInput(
          header: CoreL10n.addLoginDetailsEmailOrUsername,
          placeholder: CoreL10n.addLoginDetailsEmailOrUsernamePlaceholder,
          value: $viewModel.newLogin.login,
          focused: $isLoginEditing
        ) {
          self.isSecretKeyEditing = true
        }
        .submitLabel(.next)

        userInput(
          header: CoreL10n.addLoginDetailsSetupCode,
          placeholder: CoreL10n.addLoginDetailsSetupCodePlaceholder,
          value: $viewModel.newLogin.securityKey,
          showError: viewModel.showWrongSecretKey,
          focused: $isSecretKeyEditing
        ) {
          self.viewModel.save()
        }
        .textInputAutocapitalization(.never)
        .submitLabel(.done)
        addButton
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
    }
    .navigationBarTitleDisplayMode(.large)
    .navigationTitle(CoreL10n.addLoginDetailsTitle)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .onAppear(perform: {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.isLoginEditing = true
      }
    })
  }

  @ViewBuilder
  private func userInput(
    header: String,
    placeholder: String,
    value: Binding<String>,
    showError: Bool = false,
    focused: FocusState<Bool>.Binding,
    onSubmit: @escaping () -> Void
  ) -> some View {
    DS.TextField(
      header,
      placeholder: placeholder,
      text: value,
      feedback: {
        if showError {
          FieldTextualFeedback(CoreL10n.addLoginDetailsError)
        }
      }
    )
    .style(showError ? .error : nil)
    .focused(focused)
    .onSubmit(onSubmit)
  }

  var addButton: some View {
    Button(CoreL10n.addLoginDetailsAddCode) {
      viewModel.save()
    }
    .buttonStyle(.designSystem(.titleOnly))
    .disabled(!viewModel.userCanSave)
  }
}

#Preview {
  var credential = Credential()
  credential.login = "dashlane"
  credential.password = UUID().uuidString
  credential.url = PersonalDataURL(rawValue: "netflix")
  credential.spaceId = ""

  return NavigationView {
    AddLoginDetailsView(
      viewModel: AuthenticatorMockContainer()
        .makeAddLoginDetailsViewModel(
          website: "hello.com",
          credential: credential,
          supportDashlane2FA: true,
          completion: { _ in }
        )
    )
  }
}
