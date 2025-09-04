import CoreLocalization
import CorePersonalData
import SwiftUI
import UserTrackingFoundation

struct WiFiMenu: View {
  var wifi: WiFi
  let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

  var body: some View {
    if !wifi.ssid.isEmpty {
      CopyMenuButton(CoreL10n.WiFi.WiFiMenu.copySSID) {
        copyAction(.networkName, wifi.ssid)
      }
    }

    if !wifi.passphrase.isEmpty {
      CopyMenuButton(L10n.Localizable.copyPassword) {
        copyAction(.password, wifi.passphrase)
      }
    }
  }
}
