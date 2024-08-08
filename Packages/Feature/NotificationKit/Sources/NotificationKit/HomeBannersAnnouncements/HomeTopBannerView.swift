import Combine
import SwiftTreats
import SwiftUI

public struct HomeTopBannerView: View {
  @StateObject var model: HomeTopBannerViewModel

  public init(model: @autoclosure @escaping () -> HomeTopBannerViewModel) {
    _model = .init(wrappedValue: model())
  }

  public var body: some View {
    Group {
      if let banner = model.additionnalBanner {
        switch banner {
        case .authenticatorSunset:
          AuthenticatorSunsetBanner(model: model.authenticatorSunsetBannerViewModel)
        case .frozen:
          FrozenBanner(model: model.frozenBannerViewModel)
        case .lastpassImport:
          LastpassImportBanner(model: model.lastpassImportBannerViewModel)
        case .premium:
          PremiumAnnouncementsView(model: model.premiumAnnouncementsViewModel)
        }
      }
    }
    .onAppear { model.onAppear() }
  }

}

struct HomeTopBannerView_Previews: PreviewProvider {
  static var previews: some View {
    HomeTopBannerView(model: .mock)
  }
}
