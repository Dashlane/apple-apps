import NotificationKit
import SwiftTreats
import SwiftUI

struct HomeBottomBannerView: View {
  @StateObject var model: HomeBottomBannerViewModel

  init(model: @autoclosure @escaping () -> HomeBottomBannerViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    if model.shouldShowOnboardingBanner {
      OnboardingChecklistBanner(model: model.makeOnboardingChecklistViewModel()) {
        self.model.action(.showChecklist)
      }
    } else if model.showAutofillBanner {
      AutofillBanner(model: model.makeAutofillBannerViewModel())
    }
  }
}

struct HomeBottomBannerView_Previews: PreviewProvider {
  static var previews: some View {
    HomeBottomBannerView(model: .mock)
  }
}
