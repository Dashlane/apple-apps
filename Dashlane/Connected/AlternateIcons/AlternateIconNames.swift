import Foundation
import UIKit

final class AlternateIconNames: ObservableObject {
    @Published var currentIndex = 0
    var iconNames: [String?] = []
    let categories: [AlternateIconCategory]

    init(categories: [AlternateIconCategory]) {
        self.categories = categories
        getAlternativeIcons()
        if let currentIcon = UIApplication.shared.alternateIconName {
            self.currentIndex = iconNames.firstIndex(of: currentIcon) ?? 0
        }
    }

    private func getAlternativeIcons() {
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any], let alternateIcons = icons["CFBundleAlternateIcons"] as? [String: Any] {
            for (_, value) in alternateIcons {
                guard let iconList = value as? [String: Any] else { continue }
                guard let iconFiles = iconList["CFBundleIconFiles"] as? [String] else { continue }

                guard let icon = iconFiles.first else { continue }
                guard self.categories.contains(icon.alternateIconCategory) || icon == UIApplication.shared.alternateIconName else { continue }

                iconNames.append(icon)
            }

            iconNames.sort { $0 ?? "A" < $1 ?? "B" }
            iconNames.insert(nil, at: 0)
        }
    }

    func changeIcon(toIndex index: Int) {
        UIApplication.shared.setAlternateIconName(self.iconNames[index]) { [weak self] error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                self?.currentIndex = index
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
