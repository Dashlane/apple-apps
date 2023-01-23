import SwiftUI
import CorePersonalData
import Combine
import UIDelight
import DesignSystem

struct ItemCategoryRowView: View {
    let title: String
    let count: Int?
    let icon: SwiftUI.Image
    @ObservedObject
    var tagMessageViewModel: TagViewPublisherModel

    var tagMessage: AnyPublisher<String?, Never>?

    var countString: String {
        return count.flatMap(String.init) ?? ""
    }

    init(title: String,
         count: Int? = nil,
         icon: SwiftUI.Image,
         tagMessage: AnyPublisher<String?, Never>? = nil) {
        self.title = title
        self.count = count
        self.icon = icon
        self.tagMessage = tagMessage
        self.tagMessageViewModel = TagViewPublisherModel(tagMessage: tagMessage)
    }

    var body: some View {
        HStack(spacing: 16) {
            icon
                .frame(width: 24)
            Text(title)
                .foregroundColor(.ds.text.neutral.catchy)
                .lineLimit(1)
            Badge(tagMessageViewModel.message)
                .style(mood: .brand, intensity: .supershy)
                .hidden(tagMessageViewModel.isHidden)
            Spacer()
            if count != nil {
                Group {
                    Text(countString)
                        .id(countString)
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.ds.text.inverse.standard)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ItemCategoryRowView_Previews: PreviewProvider {
    static let models = [
        (title: "Authentifiants",
         count: 10000,
         icon: Credential.addIcon),
        (title: "Secure notes",
         count: 10,
         icon: SecureNote.addIcon),
        (title: "Payments",
         count: 10,
         icon: CreditCard.addIcon),
        (title: "Personal Informations",
         count: 10,
         icon: Identity.addIcon),
        (title: "ID documents",
         count: 10,
         icon: SocialSecurityInformation.addIcon)
    ]

    static var previews: some View {
        MultiContextPreview {
            List {
                ItemCategoryRowView(title: models[0].title, count: models[0].count, icon: models[0].icon)
                ItemCategoryRowView(title: models[1].title, count: models[1].count, icon: models[1].icon)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
