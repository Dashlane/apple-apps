#if canImport(UIKit)
  import SwiftUI
  import UIDelight
  import DesignSystem
  import CoreLocalization
  import CorePersonalData

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
            header: L10n.Core.addLoginDetailsWebsiteOrApp,
            placeholder: L10n.Core.addLoginDetailsWebsiteOrApp,
            value: $viewModel.newLogin.website,
            focused: $isWebsiteEditing
          ) {
            self.isLoginEditing = true
          }
          .submitLabel(.next)

          userInput(
            header: L10n.Core.addLoginDetailsEmailOrUsername,
            placeholder: L10n.Core.addLoginDetailsEmailOrUsernamePlaceholder,
            value: $viewModel.newLogin.login,
            focused: $isLoginEditing
          ) {
            self.isSecretKeyEditing = true
          }
          .submitLabel(.next)

          userInput(
            header: L10n.Core.addLoginDetailsSetupCode,
            placeholder: L10n.Core.addLoginDetailsSetupCodePlaceholder,
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
      .navigationTitle(L10n.Core.addLoginDetailsTitle)
      .navigationBarStyle(.brandedBarStyle)
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
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
            FieldTextualFeedback(L10n.Core.addLoginDetailsError)
          }
        }
      )
      .style(showError ? .error : nil)
      .focused(focused)
      .onSubmit(onSubmit)
    }

    var addButton: some View {
      Button(L10n.Core.addLoginDetailsAddCode) {
        viewModel.save()
      }
      .buttonStyle(.designSystem(.titleOnly))
      .disabled(!viewModel.userCanSave)
    }
  }

  struct AddLoginDetailsView_Previews: PreviewProvider {
    private static var netflixCredential: Credential {
      var credential = Credential()
      credential.login = "dashlane"
      credential.password = UUID().uuidString
      credential.url = PersonalDataURL(rawValue: "netflix")
      credential.spaceId = ""
      return credential
    }

    static var previews: some View {
      MultiContextPreview {
        NavigationView {
          AddLoginDetailsView(
            viewModel: AuthenticatorMockContainer()
              .makeAddLoginDetailsViewModel(
                website: "hello.com",
                credential: netflixCredential,
                supportDashlane2FA: true,
                completion: { _ in }
              )
          )
        }
      }
    }
  }
#endif
