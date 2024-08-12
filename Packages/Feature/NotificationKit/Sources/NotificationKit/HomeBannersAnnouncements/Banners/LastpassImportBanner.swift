import CoreLocalization
import CoreSettings
import DesignSystem
import SwiftUI
import UIDelight

public class LastpassImportBannerViewModel {
  private let deeplinkingService: NotificationKitDeepLinkingServiceProtocol
  private let userSettings: UserSettings

  public init(
    deeplinkingService: NotificationKitDeepLinkingServiceProtocol,
    userSettings: UserSettings
  ) {
    self.deeplinkingService = deeplinkingService
    self.userSettings = userSettings
  }

  func showLastpassImport() {
    deeplinkingService.handle(.importFromLastPass)
  }

  func dismiss() {
    userSettings[.lastpassImportPopupHasBeenShown] = true
  }
}

extension LastpassImportBannerViewModel {
  public static var mock: LastpassImportBannerViewModel {
    .init(
      deeplinkingService: NotificationKitDeepLinkingServiceMock(),
      userSettings: UserSettings.mock
    )
  }
}

public struct LastpassImportBanner: View {
  var model: LastpassImportBannerViewModel

  public init(model: LastpassImportBannerViewModel) {
    self.model = model
  }

  public var body: some View {
    Infobox(
      L10n.Core.importFromLastpassBannerTitle,
      description: L10n.Core.importFromLastpassBannerDescription
    ) {
      Button(L10n.Core.importFromLastpassBannerPrimaryCta) {
        self.model.showLastpassImport()
      }
      Button(L10n.Core.importFromLastpassBannerSecondaryCta) {
        self.model.dismiss()
      }
    }
    .style(mood: .neutral, intensity: .supershy)
    .padding(20)
  }
}

#Preview {
  LastpassImportBanner(model: .mock)
    .previewLayout(.sizeThatFits)
}
