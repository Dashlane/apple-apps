import CoreLocalization
import CoreTypes
import DesignSystem
import MessageUI
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct UpdateOperatingSystemAlertModifier: ViewModifier {

  @Binding
  var isPresented: Bool

  let cache: UpdateOperatingSystemCacheProtocol

  init(
    isPresented: Binding<Bool>,
    cache: UpdateOperatingSystemCacheProtocol = UpdateOperatingSystemCache()
  ) {
    self._isPresented = isPresented
    self.cache = cache
  }

  func body(content: Content) -> some View {
    content.alert(
      Text(title),
      isPresented: $isPresented,
      actions: {
        Button(CoreL10n.Announcement.UpdateSystem.notNow) {
          cache.dismiss()
        }
        Button(openSettings, role: .cancel) {
          cache.dismiss()
          openSettingsApp()
        }
      },
      message: {
        Text(CoreL10n.Announcement.UpdateSystem.message)
      })
  }

  func openSettingsApp() {
    let url: URL
    if Device.is(.mac) {
      url = URL(fileURLWithPath: "/System/Library/PreferencePanes/SoftwareUpdate.prefPane")
    } else {
      url = URL(string: "App-prefs:root=General")!
    }
    UIApplication.shared.open(url)
  }
}

extension UpdateOperatingSystemAlertModifier {
  fileprivate var title: String {
    Device.is(.mac)
      ? CoreL10n.Announcement.UpdateSystem.MacOS.title
      : CoreL10n.Announcement.UpdateSystem.Ios.title
  }

  fileprivate var message: String {
    CoreL10n.Announcement.UpdateSystem.message
  }

  fileprivate var openSettings: String {
    Device.is(.mac)
      ? CoreL10n.Announcement.UpdateSystem.MacOS.openSettings
      : CoreL10n.Announcement.UpdateSystem.Ios.openSettings
  }
}

struct UpdateOperatingSystemAlert_Previews: PreviewProvider {
  static var previews: some View {
    Color.clear.modifier(
      UpdateOperatingSystemAlertModifier(
        isPresented: .constant(true),
        cache: .mock))
  }
}
