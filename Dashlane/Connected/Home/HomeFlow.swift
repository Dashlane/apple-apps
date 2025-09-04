import Combine
import CoreLocalization
import Foundation
import SwiftTreats
import SwiftUI
import UIDelight

@ViewInit
struct HomeFlow: View {
  @StateObject
  var viewModel: HomeFlowViewModel

  var body: some View {
    currentFlow
      .sheet(item: $viewModel.genericSheet) { sheet in
        sheet.view
      }
      .fullScreenCoverOrSheet(item: $viewModel.genericFullCover) { cover in
        NavigationView {
          cover.view
        }
      }
      .onReceive(viewModel.deeplinkPublisher) { deeplink in
        switch deeplink {
        case let .importMethod(importDeeplink):
          self.viewModel.presentImport(for: importDeeplink)
        case let .vault(vaultDeeplink):
          self.viewModel.handle(vaultDeeplink)
        case let .prefilledCredential(password):
          self.viewModel.createCredential(using: password)
        default: break
        }
      }
      .homeModalAnnouncements(model: viewModel.homeModalAnnouncementsViewModel)
      .badge(viewModel.remainingActionsCount)
      .onAppear {
        viewModel.displayAnnouncementIffNeeded()
      }
  }

  @ViewBuilder
  var currentFlow: some View {
    switch viewModel.currentScreen {
    case .onboardingChecklist(let model):
      OnboardingChecklistFlow(viewModel: model)
    case .homeView(let model):
      VaultFlow(viewModel: model)
        .transition(.opacity)
    default:
      EmptyView()
    }
  }
}
