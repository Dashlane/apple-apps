import Combine
import DesignSystem
import CoreFeature
import SwiftUI
import DashTypes
import UIComponents
import CoreLocalization
import CorePersonalData
import VaultKit
import Logger
import CorePasswords
import IconLibrary
import CoreSettings

#if !os(macOS)
public struct AddCredentialView: View {
    @StateObject
    var model: AddCredentialViewModel

    @FocusState private var isWebsiteFieldFocused

    @Environment(\.dismiss)
    private var dismiss

    @State
    var showConfirmationView: Bool = false

    @FeatureState(.prideColors)
    private var isPrideColorsEnabled: Bool

    enum SubStep {
        case passwordGenerator
        case suggestionEmails
    }

    public init(model: @autoclosure @escaping () -> AddCredentialViewModel) {
        _model = .init(wrappedValue: model())
    }

    @State var substep: SubStep?

    public var body: some View {
        list
            .navigationTitle(L10n.Core.kwadddatakwAuthentifiantIOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationBarButton(L10n.Core.kwSave, action: self.save)
                }
            }
            .onAppear {
                isWebsiteFieldFocused = true
            }
            .navigation(isActive: $showConfirmationView) {
                AddCredentialConfirmationView(
                    item: model.item,
                    didFinish: model.didFinish
                )
            }
            .navigation(item: $substep, destination: { item in
                switch item {
                case .passwordGenerator:
                    PasswordGeneratorView(viewModel: model.makePasswordGeneratorViewModel())
                case .suggestionEmails:
                    SuggestionsDetailView(items: model.emails.map(\.value), selection: $model.item.email)
                }
            }, hidden: true)
    }

    @ViewBuilder
    var list: some View {
        List {
            content
                .textFieldAppearance(.grouped)
                .environment(\.detailMode, .adding())
        }
        .detailListStyle()
    }

    @ViewBuilder
    var content: some View {
        Group {
            Section(L10n.Core.addCredentialWebsiteSection) {
                website
            }
            if model.hasSpaceSelection {
                Section(L10n.Core.addCredentialWebsiteSpace) {
                    spaceSelector
                }
            }
            Section(L10n.Core.addCredentialWebsiteLogin) {
                email
                password
            }
        }
    }

    @ViewBuilder
    var website: some View {
                DS.TextField(L10n.Core.KWAuthentifiantIOS.urlStringForUI,
                     text: $model.item.editableURL)
            .focused($isWebsiteFieldFocused)
    }

    @ViewBuilder
    var spaceSelector: some View {
        HStack {
            UserSpaceIcon(space: model.selectedSpace, size: .normal)
                .equatable()
                .padding(4)
            Text(model.selectedSpace.teamName)
                .foregroundColor(.ds.text.brand.standard)
                .font(.subheadline.weight(.regular))

            if model.spaceIsSwitchable {
                Spacer()

                Menu(content: {
                    ForEach(model.availableUserSpaces) { space in
                        Button {
                            model.selectedSpace = space
                        } label: {
                            Text(space.teamName)
                        }
                        .eraseToAnyView()
                    }
                }, label: {
                    Image.ds.action.more.outlined
                })
            }
        }
    }

    @ViewBuilder
    var email: some View {
                DS.TextField(model.loginIsMail ? L10n.Core.KWAuthentifiantIOS.email : L10n.Core.KWAuthentifiantIOS.login,
                     placeholder: "\(L10n.Core.KWAuthentifiantIOS.email) / \(L10n.Core.KWAuthentifiantIOS.login)",
                     text: $model.login,
                     actions: {
            if !model.emails.isEmpty {
                TextFieldAction.Menu(L10n.Core.detailItemViewAccessibilitySelectEmail, image: .ds.action.more.outlined) {
                    ForEach(model.emails) { email in
                        Button(action: {
                            model.login = email.value
                        }, title: email.value)
                    }
                }
            }
        })
        .textContentType(.emailAddress)
    }

    @ViewBuilder
    var password: some View {
        VStack(spacing: 4) {
                        DS.TextField(L10n.Core.KWAuthentifiantIOS.password, text: $model.item.password, actions: {
                TextFieldAction.Button("",
                                       image: .ds.action.refresh.outlined,
                                       action: model.refreshPassword)
            })
            .secureInput()
            .textFieldRevealSecureValue(model.shouldReveal)
            .textFieldColorHighlightingMode(.password)

            passwordAccessory

            DS.Button(L10n.Core.addCredentialGeneratorCTA, action: { substep = .passwordGenerator })
                .style(mood: .brand, intensity: .supershy)
                .padding(.top)

        }
    }

        @ViewBuilder
    private var passwordAccessory: some View {
        TextFieldPasswordStrengthFeedback(strength: model.passwordStrength, colorful: isPrideColorsEnabled)
            .animation(.default, value: model.passwordStrength)
    }

    private func save() {
        model.prepareForSaving()
        model.save()
        showConfirmationView = true
    }
}

struct AddCredentialView_Previews: PreviewProvider {
    static var viewModel: AddCredentialViewModel {
        let email1 = Email(value: "_", name: "Test 1")
        let email2 = Email(value: "_", name: "Test 2")

        return AddCredentialViewModel.mock(existingItems: [email1, email2], hasBusinessTeam: true)
    }

    static var previews: some View {
        AddCredentialView(model: Self.viewModel)
    }
}
#endif
