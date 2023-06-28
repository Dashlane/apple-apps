import Foundation
import UIKit

final class AlternateIconNames: ObservableObject {

    @Published var currentIcon: Icon
    let icons: [Icon]

    enum Icon: Equatable {
        case primary(String)
        case dynamic(String)

        var name: String {
            switch self {
            case let .primary(name):
                return name
            case let .dynamic(name):
                return name
            }
        }
    }

    init(categories: [AlternateIconCategory]) {

        let dynamicIcons = Bundle.main.alternateIcons()
            .sorted()
            .filter({ categories.contains($0.alternateIconCategory) || $0 == UIApplication.shared.alternateIconName })
            .map({ Icon.dynamic($0) })

        self.icons = [
                        .primary(Bundle.main.primaryIconName)
        ] + dynamicIcons

        if let name = UIApplication.shared.alternateIconName, let currentIcon = icons.first(where: { $0.name == name }) {
            self.currentIcon = currentIcon
        } else {
            self.currentIcon = .primary(Bundle.main.primaryIconName)
        }
    }

    func changeIcon(to icon: Icon) {
        guard case let .dynamic(name) = icon else {
                        UIApplication.shared.setAlternateIconName(nil)
            self.currentIcon = icon
            return
        }
        UIApplication.shared.setAlternateIconName(name) { [weak self] error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                self?.currentIcon = icon
            }
        }
    }
}

enum AlternateIconCategory {
    case brand
    case pride
}

private extension String {
    var alternateIconCategory: AlternateIconCategory {
        switch self {
            case "8_PrideIcon":
                return .pride
            default:
                return .brand
        }
    }
}

extension Bundle {
    var primaryIconName: String {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else {
            return "AppIcon"
        }
        return lastIcon
    }

    func alternateIcons() -> [String] {
        guard let bundleIcons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any], let alternateIcons = bundleIcons["CFBundleAlternateIcons"] as? [String: Any] else {
            return []
        }

        return alternateIcons.compactMap({ _, value -> String? in
            guard let iconData = value as? [String: String] else { return nil }
            guard let icon = iconData["CFBundleIconName"] else { return nil }
            return icon
        })
    }
}
