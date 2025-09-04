import DesignSystem
import SwiftUI
import UIDelight

struct OnboardingChecklistBanner: View {
  @StateObject var model: OnboardingChecklistViewModel
  let action: () -> Void

  init(
    model: @autoclosure @escaping () -> OnboardingChecklistViewModel,
    action: @escaping () -> Void
  ) {
    self._model = .init(wrappedValue: model())
    self.action = action
  }

  var body: some View {
    if let onboardingAction = model.selectedAction {
      Button(action: action) {
        Label {
          Text(onboardingAction.title)
        } icon: {
          Text("\(onboardingAction.index)/\(model.actions.count)")
            .alignmentGuide(.top, computeValue: { _ in -3 })
            .foregroundStyle(Color.ds.text.inverse.standard)
            .textStyle(.component.button.small)
            .fixedSize()
        }
        .padding(.vertical, 8)
      }
      .buttonStyle(.designSystem(.iconLeading))
      .padding(.vertical, 16)
      .padding(.horizontal, 20)
    }
  }
}

#Preview {
  OnboardingChecklistBanner(model: .mock, action: {})
}
