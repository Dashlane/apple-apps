import SwiftUI

import MessageUI
import UIComponents
import DashTypes
import CoreLocalization
import SwiftTreats
import UIDelight
import DesignSystem

struct UpdateOperatingSystemAlertModifier: ViewModifier {

    @Binding
    var isPresented: Bool

    let cache: UpdateOperatingSystemCacheProtocol

    init(isPresented: Binding<Bool>,
         cache: UpdateOperatingSystemCacheProtocol = UpdateOperatingSystemCache()) {
        self._isPresented = isPresented
        self.cache = cache
    }

    func body(content: Content) -> some View {
        content.alert(Text(title),
                      isPresented: $isPresented,
                      actions: {
            Button(L10n.Core.Announcement.UpdateSystem.notNow) {
                cache.dismiss()
            }
            Button(openSettings, role: .cancel) {
                cache.dismiss()
                openSettingsApp()
            }
        }, message: {
            Text(L10n.Core.Announcement.UpdateSystem.message)
        })
    }

    func openSettingsApp() {
        let url: URL
        if Device.isMac {
            url = URL(fileURLWithPath: "/System/Library/PreferencePanes/SoftwareUpdate.prefPane")
        } else {
            url = URL(string: "App-prefs:root=General")!
        }
        UIApplication.shared.open(url)
    }
}

private extension UpdateOperatingSystemAlertModifier {
    var title: String {
        Device.isMac ? L10n.Core.Announcement.UpdateSystem.MacOS.title : L10n.Core.Announcement.UpdateSystem.Ios.title
    }

    var message: String {
        L10n.Core.Announcement.UpdateSystem.message
    }

    var openSettings: String {
        Device.isMac ? L10n.Core.Announcement.UpdateSystem.MacOS.openSettings : L10n.Core.Announcement.UpdateSystem.Ios.openSettings
    }
}

struct UpdateOperatingSystemAlert_Previews: PreviewProvider {
    static var previews: some View {
        Color.clear.modifier(UpdateOperatingSystemAlertModifier(isPresented: .constant(true),
                                                                cache: .mock))
    }
}
