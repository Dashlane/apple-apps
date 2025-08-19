import Foundation

extension WiFi {
  public var qrCodeURL: String {
    if self.passphrase.isEmpty {
      return "WIFI:S:\(self.ssid);;"
    } else {
      return "WIFI:T:WPA;S:\(self.ssid);P:\(self.passphrase);;"
    }
  }
}
