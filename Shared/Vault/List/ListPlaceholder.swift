import DesignSystem
import SwiftUI

struct ListPlaceholder: View {
    let icon: Image
    let text: String
    let accessory: AnyView?

    init(icon: Image,
         text: String,
         accessory: AnyView?) {
        self.icon = icon
        self.text = text
        self.accessory = accessory
    }

    fileprivate init(icon: Image, text: String) {
        self.icon = icon
        self.text = text
        self.accessory = nil
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                icon.fiberAccessibilityHidden(true)
                Spacer().frame(maxHeight: 50)
                Text(text)
                    .foregroundColor(.ds.text.neutral.quiet)
                    .multilineTextAlignment(.center)
            }
            if let accessory = accessory {
                Spacer().frame(maxHeight: 40)
                accessory
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 30)
        .padding(.vertical, 5)
    }
}

extension ListPlaceholder {
    init(category: ItemCategory,
         accessory: AnyView?) {
        self.init(icon: category.placeholderIcon,
                  text: category.placeholder,
                  accessory: accessory)
    }
}

struct ListPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListPlaceholder(icon: ItemCategory.credentials.placeholderIcon,
                            text: ItemCategory.credentials.placeholder)
            ListPlaceholder(category: ItemCategory.credentials, accessory: nil)
        }

    }
}
