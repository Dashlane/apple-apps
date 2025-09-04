import Foundation
import SwiftUI
import UIDelight

struct OnboardingChecklistFlow: View {

  @StateObject
  var viewModel: OnboardingChecklistFlowViewModel

  init(viewModel: @autoclosure @escaping () -> OnboardingChecklistFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .onboardingChecklist:
        OnboardingChecklistView(
          model: viewModel.makeOnboardingChecklistViewModel(),
          displayMode: viewModel.displayMode
        ) {
          viewModel.dismiss()
        }
      }
    }
    .fullScreenCover(item: $viewModel.genericFullCover) { fullCover in
      fullCover.view
    }
    .sheet(item: $viewModel.genericSheet) { sheet in
      sheet.view
    }
  }
}
