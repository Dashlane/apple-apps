import SwiftUI
import UIDelight
import DesignSystem

struct AddLoginDetailsView: View {

    @StateObject
    var viewModel: AddLoginDetailsViewModel
    
    init(viewModel: @autoclosure @escaping () -> AddLoginDetailsViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }
    
    @FocusState
    var isWebsiteEditing: Bool
    @FocusState
    var isLoginEditing: Bool
    @FocusState
    var isSecretKeyEditing: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                userInput(header: L10n.Localizable.addLoginDetailsWebsiteOrApp,
                          placeholder: L10n.Localizable.addLoginDetailsWebsiteOrApp,
                          value: $viewModel.newLogin.website,
                          focused: $isWebsiteEditing) {
                    self.isLoginEditing = true
                }
                          .submitLabel(.next)
                
                userInput(header: L10n.Localizable.addLoginDetailsEmailOrUsername,
                          placeholder: L10n.Localizable.addLoginDetailsEmailOrUsernamePlaceholder,
                          value: $viewModel.newLogin.login,
                          focused: $isLoginEditing) {
                    self.isSecretKeyEditing = true
                }
                          .submitLabel(.next)
                
                userInput(header: L10n.Localizable.addLoginDetailsSetupCode,
                          placeholder: L10n.Localizable.addLoginDetailsSetupCodePlaceholder,
                          value: $viewModel.newLogin.securityKey,
                          showError: viewModel.showWrongSecretKey,
                          focused: $isSecretKeyEditing) {
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
        .navigationTitle(L10n.Localizable.addLoginDetailsTitle)
        .navigationBarStyle(.brandedBarStyle)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoginEditing = true
            }
        })
    }
    
    @ViewBuilder
    private func userInput(header: String,
                           placeholder: String,
                           value: Binding<String>,
                           showError: Bool = false,
                           focused: FocusState<Bool>.Binding,
                           onSubmit: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                TextInput(placeholder, text: value)
                    .focused(focused)
                    .onSubmit(onSubmit)
                    .textInputLabel(header)
                VStack {
                    if showError {
                        HStack {
                            Text(L10n.Localizable.addLoginDetailsError)
                                .font(.footnote)
                                .foregroundColor(.ds.border.danger.standard.active)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .frame(minHeight: 24)
            }
        }
    }
    
    var addButton: some View {
        RoundedButton(L10n.Localizable.addLoginDetailsAddCode, action: viewModel.save)
            .roundedButtonLayout(.fill)
            .disabled(!viewModel.userCanSave)
    }
}

struct AddLoginDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            NavigationView {
                AddLoginDetailsView(viewModel: AuthenticatorMockContainer().makeAddLoginDetailsViewModel(website: "hello.com",
                                                                                                         credential: PersonalDataMock.Credentials.netflix,
                                                                                                         completion:  { _ in
                    
                }))
            }
        }
    }
}
