import SwiftUI
import SwiftTreats

struct DomainsSectionView: View {
    let sectionTitle: String
    let domains: [String]
    var isOpenable: Bool

    var body: some View {
        if domains.count > 0 {
            Section(header: Text(sectionTitle.uppercased())) {
                ForEach(domains, id: \.self) { item in
                    Text(item)
                        .action(L10n.Localizable.kwGoToUrl, isHidden: (!isOpenable || item.openableURL == nil)) {
                            guard let url = item.openableURL else {
                                return
                            }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                }
            }
        }
    }
}
