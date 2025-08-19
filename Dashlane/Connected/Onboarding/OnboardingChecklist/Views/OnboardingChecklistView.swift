import CoreLocalization
import DesignSystem
import Foundation
import NotificationKit
import SwiftUI
import UIDelight
import UserTrackingFoundation
import VaultKit

struct OnboardingChecklistView: View {

  @StateObject
  var model: OnboardingChecklistViewModel

  @State
  private var isPresentingImportView = false

  let displayMode: OnboardingChecklistFlowViewModel.DisplayMode
  let dismiss: () -> Void

  init(
    model: @escaping @autoclosure () -> OnboardingChecklistViewModel,
    displayMode: OnboardingChecklistFlowViewModel.DisplayMode, dismiss: @escaping () -> Void
  ) {
    self._model = .init(wrappedValue: model())
    self.displayMode = displayMode
    self.dismiss = dismiss
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 12) {
        if model.actions.contains(.addFirstPasswordsManually) {
          addPasswordsManually
        }
        if model.actions.contains(.activateAutofill) {
          activateAutofill
        }
        if model.actions.contains(.mobileToDesktop) {
          m2w
        }
        if model.dismissability != .nonDismissable {
          dismissButton
        }
      }
      .padding(16)
      .animation(.spring(), value: model.selectedAction)
    }
    .background(backgroundColor.edgesIgnoringSafeArea(.vertical))
    .toolbar(content: {
      ToolbarItem(placement: .navigationBarLeading) {
        if displayMode == .modal {
          Button(
            action: dismiss,
            label: {
              Text(CoreL10n.kwButtonClose)
                .foregroundStyle(Color.ds.text.brand.standard)
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
    .navigationTitle(
      displayMode == .modal ? L10n.Localizable.onboardingChecklistTitle : CoreL10n.mainMenuHomePage
    )
    .onAppear(perform: model.updateOnAppear)
    .reportPageAppearance(userTrackingPage)
    .sheet(isPresented: $isPresentingImportView) {
      ImportView(importSource: .vaultList)
    }
  }

  var backgroundColor: Color {
    .ds.background.alternate
  }

  @ViewBuilder
  var addButton: some View {
    AddVaultButton(
      isImportEnabled: true,
      onAction: { action in
        switch action {
        case .add(let itemType):
          self.model.addNewItemAction(mode: .itemType(itemType))
        case .import:
          isPresentingImportView = true
        }
      }
    )
  }

  var addPasswordsManually: some View {
    OnboardingChecklistItemView(
      showDetails: model.selectedAction == .addFirstPasswordsManually,
      completed: model.hasPassedPasswordOnboarding,
      action: .addFirstPasswordsManually,
      ctaAction: { self.model.start(.addFirstPasswordsManually) }
    ).onTapGesture { self.model.select(.addFirstPasswordsManually) }
  }

  var activateAutofill: some View {
    OnboardingChecklistItemView(
      showDetails: model.selectedAction == .activateAutofill,
      completed: model.isAutofillActivated,
      action: .activateAutofill,
      ctaAction: { self.model.start(.activateAutofill) }
    ).onTapGesture {
      self.model.select(.activateAutofill)
    }
  }

  var m2w: some View {
    OnboardingChecklistItemView(
      showDetails: model.selectedAction == .mobileToDesktop,
      completed: model.hasFinishedM2WAtLeastOnce,
      action: .mobileToDesktop,
      ctaAction: { self.model.start(.mobileToDesktop) }
    ).onTapGesture { self.model.select(.mobileToDesktop) }
  }

  var dismissButton: some View {
    Button(
      action: {
        self.model.didTapDismiss()
        UIAccessibility.fiberPost(
          .screenChanged, argument: L10n.Localizable.accessibilityOnboardingChecklistDismissed)
      },
      label: {
        Text(model.dismissButtonCTA ?? "")
          .foregroundStyle(Color.ds.text.brand.standard)
          .bold()
      }
    )
    .padding(10)
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
      OnboardingChecklistView(model: .mock, displayMode: .root, dismiss: {})
    }
  }
}
