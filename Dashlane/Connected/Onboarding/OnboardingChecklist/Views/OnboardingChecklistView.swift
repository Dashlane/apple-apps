import Foundation
import SwiftUI
import UIDelight
import CoreUserTracking
import NotificationKit

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
                if model.actions.contains(.m2d) {
                    m2w
                }
                dismissButton
            }
            .padding(16)
            .animation(.spring(), value: model.selectedAction)
                                    .homeModalAnnouncements(model: model.modalAnnouncementsViewModel)
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.bottom))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                if displayMode == .modal {
                    Button(action: dismiss, label: {
                        Text(L10n.Localizable.kwButtonClose)
                            .foregroundColor(Color(asset: FiberAsset.accentColor))
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
        .navigationTitle(displayMode == .modal ? L10n.Localizable.onboardingChecklistTitle : L10n.Localizable.mainMenuHomePage)
        .onAppear(perform: model.updateOnAppear)
        .reportPageAppearance(userTrackingPage)
    }

    var backgroundColor: Color {
        return Color(asset: FiberAsset.appBackground)
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
        OnboardingChecklistItemView(showDetails: model.selectedAction == .m2d,
                                    completed: model.hasFinishedM2WAtLeastOnce,
                                    action: .m2d,
                                    ctaAction: { self.model.start(.m2d) }).onTapGesture { self.model.showDetails(.m2d) }
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
                .foregroundColor(Color(asset: FiberAsset.midGreen))
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
