import Foundation
import SwiftUI
import Combine
import CorePasswords
import UIComponents
import VaultKit

struct AddCredentialView: View {
    @StateObject
    var model: AddCredentialViewModel

    @State
    private var websiteFieldFocused: Bool = false

    @Environment(\.dismiss)
    private var dismiss

    @State
    var showConfirmationView: Bool = false

    enum SubStep {
        case passwordGenerator
        case suggestionEmails
    }
    
    @State var substep: SubStep?
    
    var body: some View {
        list
            .navigationTitle(L10n.Localizable.kwadddatakwAuthentifiantIOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationBarButton(L10n.Localizable.kwSave, action: self.save)
                }
            }
            .onAppear {
                websiteFieldFocused = true
            }
            .navigation(isActive: $showConfirmationView) {
                AddCredentialConfirmationView(item: model.item,
                                              iconViewModel: model.makeIconViewModel(),
                                              didFinish: model.didFinish)
            }
    }
    
    var list: some View {
        List {
            content
                .environment(\.detailMode, .adding())
        }
        .detailListStyle()
    }
    
    @ViewBuilder
    var content: some View {
                TextDetailField(title: L10n.Localizable.KWAuthentifiantIOS.urlStringForUI,
                        text: $model.item.editableURL,
                        placeholder: L10n.Localizable.KWAuthentifiantIOS.url,
                        isFocused: $websiteFieldFocused)
        
                TextDetailField(title: L10n.Localizable.KWAuthentifiantIOS.email,
                        text: $model.item.email,
                        placeholder: L10n.Localizable.kwEmailPlaceholder)
            .textContentType(.emailAddress)
            .suggestion(value: $model.item.email,
                        suggestions: model.emails.map(\.value),
                        showSuggestions: .init(get: { self.substep == .suggestionEmails },
                                               set: { self.substep = $0 ? .suggestionEmails : nil }))
        
        
        VStack(spacing: 4) {
                        SecureDetailField(title: L10n.Localizable.KWAuthentifiantIOS.password,
                              text: $model.item.password,
                              shouldReveal: $model.shouldReveal,
                              action: { _ in self.model.shouldReveal.toggle() },
                              usagelogSubType: .password)
            
                        passwordAccessory
        }
        .navigation(item: $substep,
                    destination: { item in
            switch item {
            case .passwordGenerator:
                PasswordGeneratorView(viewModel: model.makePasswordGeneratorViewModel())
            case .suggestionEmails:
                SuggestionsDetailView(items:
                                        model.emails.map(\.value),
                                      selection: $model.item.email)
            }
        })
    }
    
        private var passwordAccessory: some View {
        ZStack {
            if model.item.password.isEmpty {
                Button(action: { self.substep = .passwordGenerator }, title: L10n.Localizable.kwGenerate)
                    .accentColor(Color(asset: FiberAsset.accentColor))
                    .padding(7)
            } else {
                PasswordStrengthDetailField(passwordStrength: model.passwordStrength)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .animation(.default, value: model.item.password.isEmpty)
    }
    
    private func save() {
        model.prepareForSaving()
        model.save()
        showConfirmationView = true
    }
}
