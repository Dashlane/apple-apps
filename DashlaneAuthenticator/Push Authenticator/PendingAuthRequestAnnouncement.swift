import SwiftUI
import UIDelight
import DesignSystem

struct PendingAuthRequestAnnouncement: View {

    enum Action {
        case ignore
        case show
    }
    let expiryDate: Date
    let completion: (Action) -> Void

    let timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .default).autoconnect()

    var body: some View {
        Infobox(title: L10n.Localizable.pendingAuthRequestAnnouncementTitleDashlane) {
            Button(action: { completion(.show) },
                   title: L10n.Localizable.pendingAuthRequestAnnouncementDetailButton)
            Button(action: { completion(.ignore) },
                   title: L10n.Localizable.pendingAuthRequestAnnouncementIgnoreButton)
        }
        .onReceive(timer) { _ in
            if expiryDate < Date() {
                completion(.ignore)
            }
        }
    }
}

struct PendingAuthRequestAnnouncement_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            PendingAuthRequestAnnouncement(expiryDate: Date(timeIntervalSinceNow: 10)) {_ in}

            .previewLayout(.sizeThatFits)
        }
    }
}
