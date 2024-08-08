import DesignSystem
import SwiftUI
import UIDelight

struct PendingAuthRequestAnnouncement: View {

  enum Action {
    case ignore
    case show
  }
  let expiryDate: Date
  let completion: (Action) -> Void

  let timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .default).autoconnect()

  var body: some View {
    Infobox(L10n.Localizable.pendingAuthRequestAnnouncementTitleDashlane) {
      Button(L10n.Localizable.pendingAuthRequestAnnouncementDetailButton) {
        completion(.show)
      }
      Button(L10n.Localizable.pendingAuthRequestAnnouncementIgnoreButton) {
        completion(.ignore)
      }
    }
    .onReceive(timer) { _ in
      if expiryDate < Date() {
        completion(.ignore)
      }
    }
  }
}

#Preview {
  PendingAuthRequestAnnouncement(expiryDate: Date(timeIntervalSinceNow: 10)) { _ in }
}
