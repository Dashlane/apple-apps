import DesignSystem
import SwiftUI
import UIDelight
import SwiftTreats

struct FAQItemView: View {
    var item: FAQItem

    @Binding
    var selectedItem: FAQItem?

    @Environment(\.openURL)
    var openURL

    private var isCollapsed: Bool { selectedItem == item }

    enum Completion {
        case opened(_ item: FAQItem)
        case closed
    }

    var completion: ((Completion) -> Void)?

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .center) {
                Text(item.title)
                    .font(.headline.weight(.regular))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Image.ds.caretUp.outlined
                    .foregroundColor(Color(asset: FiberAsset.grey01))
                    .rotationEffect(.degrees(isCollapsed ? 0 : 180), anchor: .center)
                    .fiberAccessibilityHidden(true)
            }
            .fiberAccessibilityElement()
            .fiberAccessibilityLabel(Text(item.title) + Text(isCollapsed ? L10n.Localizable.accessibilityCollapse  : L10n.Localizable.accessibilityExpand))
            .fiberAccessibilityAddTraits(.isButton)
            .fiberAccessibilityAction {
                toggleCollapse()
            }

            VStack(alignment: .leading, spacing: 16) {
                ForEach(item.descriptions, id: \.self) { description in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(description.title)
                            .foregroundColor(Color(asset: FiberAsset.neutralText))
                            .fixedSize(horizontal: false, vertical: true)
                        if let link = description.link {
                            Button(action: { openURL(link.url) }, title: link.label)
                                .accessibilityAddTraits(.isLink)
                        }
                    }
                }
            }
            .font(Device.isMac ? .subheadline : .footnote)
            .hidden(!isCollapsed)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(asset: FiberAsset.listBackground)
                                .onTapGesture {
                toggleCollapse()
            })
        .cornerRadius(4)
    }

    private func toggleCollapse() {
        withAnimation(.spring()) {
            self.completion?(isCollapsed ? .closed : .opened(self.item))
        }
    }
}

struct FAQItemView_Previews: PreviewProvider {

    static var faqItem = FAQItem(title: "What is the meaning of life?",
                                 description: .init(title: "description", link: .init(label: "Link", url: URL(string: "_")!)))

    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            FAQItemView(item: faqItem, selectedItem: .constant(nil))
        }.previewLayout(.sizeThatFits)
    }
}
