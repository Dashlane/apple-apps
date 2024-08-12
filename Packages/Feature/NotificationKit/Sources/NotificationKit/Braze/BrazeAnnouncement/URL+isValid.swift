import Foundation

extension URL {
  func isValidBrazeAction() -> Bool {
    if self.scheme == "dashlane" {
      return true
    } else if let host = self.host,
      host == "dashlane.com" || host.hasSuffix(".dashlane.com") == true
    {
      return true
    }
    return false
  }
}
