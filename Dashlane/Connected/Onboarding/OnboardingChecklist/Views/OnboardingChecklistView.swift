import DesignSystem
import Foundation
import SwiftUI
import UIDelight
import CoreUserTracking
import NotificationKit
import VaultKit
import CoreLocalization

struct OnboardingChecklistView: View {

    @ObservedObject
    var model: OnboardingChecklistViewModel

    let displayMode: OnboardingChecklistFlowViewModel.DisplayMode
    let dismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                                if model.actions.contains(.addFirstPasswordsManually) {
                    addPasswordsManually
                }
                if model.actions.contains(.importFromBrowser) {
                    importPasswordsFromBrowser
                }
                if model.actions.contains(.fixBreachedAccounts) {
                    fixBreachedAccounts
                }
                if model.actions.contains(.seeScanResult) {
                    seeScanResult
                }
                if model.actions.contains(.activateAutofill) {
                    activateAutofill
                }
                if model.actions.contains(.mobileToDesktop) {
                    m2w
                }
                dismissButton
            }
            .padding(16)
            .animation(.spring(), value: model.selectedAction)
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.bottom))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                if displayMode == .modal {
                    Button(action: dismiss, label: {
                        Text(CoreLocalization.L10n.Core.kwButtonClose)
                            .foregroundColor(.ds.text.brand.standard)
                            .fontWeight(.regular)
                    })
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if displayMode != .modal {
                    addButton
                }
            }
        })
        .navigationBarBackButtonHidden(displayMode != .modal)
        .navigationTitle(displayMode == .modal ? L10n.Localizable.onboardingChecklistTitle : CoreLocalization.L10n.Core.mainMenuHomePage)
        .onAppear(perform: model.updateOnAppear)
        .reportPageAppearance(userTrackingPage)
    }

    var backgroundColor: Color {
        .ds.background.alternate
    }

    @ViewBuilder
    var addButton: some View {
        AddVaultButton(secureNoteState: model.secureNoteState,
                       onTap: model.onAddItemDropdown) { itemType in
            self.model.addNewItemAction(mode: .itemType(itemType))
        }
    }

    var addPasswordsManually: some View {
        OnboardingChecklistItemView(showDetails: model.selectedAction == .addFirstPasswordsManually,
                                    completed: model.hasAtLeastOnePassword,
                                    action: .addFirstPasswordsManually,
                                    ctaAction: { self.model.start(.addFirstPasswordsManually) }).onTapGesture { self.model.showDetails(.addFirstPasswordsManually) }
    }

    var importPasswordsFromBrowser: some View {
        OnboardingChecklistItemView(showDetails: model.selectedAction == .importFromBrowser,
                                    completed: model.hasAtLeastOnePassword,
                                    action: .importFromBrowser,
                                    ctaAction: { self.model.start(.importFromBrowser) }).onTapGesture {
                                        self.model.showDetails(.importFromBrowser) }
    }

    var activateAutofill: some View {
        OnboardingChecklistItemView(showDetails: model.selectedAction == .activateAutofill,
                                    completed: model.isAutofillActivated,
                                    action: .activateAutofill,
                                    ctaAction: { self.model.start(.activateAutofill) }).onTapGesture {
                                        self.model.showDetails(.activateAutofill) }
    }

    var m2w: some View {
        OnboardingChecklistItemView(showDetails: model.selectedAction == .mobileToDesktop,
                                    completed: model.hasFinishedM2WAtLeastOnce,
                                    action: .mobileToDesktop,
                                    ctaAction: { self.model.start(.mobileToDesktop) }).onTapGesture { self.model.showDetails(.mobileToDesktop) }
    }

    var fixBreachedAccounts: some View {
        OnboardingChecklistItemView(showDetails: model.selectedAction == .fixBreachedAccounts,
                                    completed: model.hasSeenDWMExperience,
                                    action: .fixBreachedAccounts,
                                    ctaAction: { self.model.start(.fixBreachedAccounts) }).onTapGesture { self.model.showDetails(.fixBreachedAccounts) }
    }

    var seeScanResult: some View {
        OnboardingChecklistItemView(showDetails: model.selectedAction == .seeScanResult,
                                    completed: model.hasAtLeastOnePassword,
                                    action: .seeScanResult,
                                    ctaAction: { self.model.start(.seeScanResult) }).onTapGesture { self.model.showDetails(.seeScanResult) }
    }

    var dismissButton: some View {
        Button(action: {
            self.model.didTapDismiss()
            UIAccessibility.fiberPost(.screenChanged, argument: L10n.Localizable.accessibilityOnboardingChecklistDismissed)
        }, label: {
            Text(model.dismissButtonCTA ?? "")
                .foregroundColor(.ds.text.brand.standard)
                .bold()
        })
        .padding(10)
        .hidden(model.dismissability == .nonDismissable)
    }

    private var userTrackingPage: Page {
        switch displayMode {
        case .root:
            return .homeOnboardingChecklist
        case .modal:
            return .homeOnboardingChecklistModalDisplay
        }
    }
}

struct OnboardingChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            OnboardingChecklistView(model: .mock, displayMode: .root, dismiss: { })
        }
    }
}
