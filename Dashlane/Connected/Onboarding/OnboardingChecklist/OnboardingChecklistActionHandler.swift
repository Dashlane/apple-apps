import Combine
import CoreFeature
import Foundation
import NotificationKit
import SwiftUI

struct GenericSheet: Identifiable, Equatable {
  let id = UUID()
  let view: AnyView

  init(view: some View) {
    self.view = view.eraseToAnyView()
  }

  static func == (lhs: GenericSheet, rhs: GenericSheet) -> Bool {
    return lhs.id == rhs.id
  }
}

enum OnboardingChecklistOrigin {
  case home
  case standalone

  var shouldEmbedNavigationView: Bool {
    return self == .standalone
  }
}

@MainActor
protocol OnboardingChecklistActionHandler: AnyObject {
  var genericSheet: GenericSheet? { get set }
  var genericFullCover: GenericSheet? { get set }
  var origin: OnboardingChecklistOrigin { get }

  var sessionServices: SessionServicesContainer { get }
  func handleOnboardingChecklistViewAction(_ action: OnboardingChecklistFlowViewModel.Action)
  func dismissOnboardingChecklistFlow()
}

@MainActor
extension OnboardingChecklistActionHandler {
  func handleOnboardingChecklistViewAction(_ action: OnboardingChecklistFlowViewModel.Action) {
    switch action {
    case let .addNewItem(displayMode):
      addNewItem(displayMode: displayMode)
    case let .ctaTapped(action):
      ctaTapped(for: action)
    case .onDismiss:
      dismissOnboardingChecklistFlow()
    default: break
    }
  }

  func presentSheet(_ sheet: GenericSheet) {
    genericSheet = sheet
  }

  func presentFullCover(_ cover: GenericSheet) {
    genericFullCover = cover
  }

  func dismissSheet() {
    genericSheet = nil
  }

  func dismissFullCover() {
    genericFullCover = nil
  }

  private func presentSheet(_ view: some View) {
    presentSheet(GenericSheet(view: view.eraseToAnyView()))
  }

  private func presentFullCover(_ view: some View) {
    presentFullCover(GenericSheet(view: view.eraseToAnyView()))
  }

  func addNewItem(displayMode: AddItemFlowViewModel.DisplayMode) {
    let viewModel = sessionServices.makeAddItemFlowViewModel(displayMode: displayMode) {
      [weak self] _ in
      self?.dismissFullCover()
    }
    presentFullCover(
      AddItemFlow(viewModel: viewModel)
        .embedInNavigationView(origin.shouldEmbedNavigationView)
    )
  }

  func ctaTapped(for action: OnboardingChecklistAction) {
    switch action {
    case .addFirstPasswordsManually:
      presentFullCover(ImportView(importSource: .onboardingChecklist))
    case .activateAutofill:
      Task { @MainActor in
        let model = sessionServices.viewModelFactory.makeAutofillOnboardingFlowViewModel {
          [weak self] in
          self?.dismissSheet()
        }
        self.presentSheet(AutofillOnboardingFlowView(model: model))
      }
    case .mobileToDesktop:
      let settings = M2WSettings(userSettings: sessionServices.spiegelUserSettings)
      let viewModel = M2WFlowViewModel(initialStep: .connect)
      let view = M2WFlowView(viewModel: viewModel) { [weak self] dismissAction in
        switch dismissAction {
        case .success:
          settings.setUserHasFinishedM2W()
          fallthrough
        case .canceled:
          self?.dismissSheet()
        }
      }
      presentSheet(view)
    }
  }
}

extension View {
  @ViewBuilder
  func embedInNavigationView(_ shouldEmbedNavigationView: Bool) -> some View {
    if shouldEmbedNavigationView {
      NavigationView {
        self
      }
    } else {
      self
    }
  }
}
