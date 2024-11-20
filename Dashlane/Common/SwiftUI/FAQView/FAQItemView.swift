import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight

struct FAQItemView: View {
  var item: FAQItem

  @Binding
  var selectedItem: FAQItem?

  @Environment(\.openURL)
  var openURL

  private var isCollapsed: Bool { selectedItem == item }

  var body: some View {

    VStack(alignment: .leading, spacing: 16) {

      HStack(alignment: .center) {
        Text(item.title)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .font(.headline.weight(.regular))
          .fixedSize(horizontal: false, vertical: true)

        Spacer()

        Image.ds.caretUp.outlined
          .foregroundStyle(Color.ds.border.neutral.standard.idle)
          .rotationEffect(.degrees(isCollapsed ? 0 : 180), anchor: .center)
          .fiberAccessibilityHidden(true)
      }
      .fiberAccessibilityElement()
      .fiberAccessibilityLabel(
        Text(item.title)
          + Text(
            isCollapsed
              ? L10n.Localizable.accessibilityCollapse : L10n.Localizable.accessibilityExpand)
      )
      .fiberAccessibilityAddTraits(.isButton)
      .fiberAccessibilityAction {
        toggleCollapse()
      }

      if isCollapsed {
        VStack(alignment: .leading, spacing: 16) {
          ForEach(item.descriptions, id: \.self) { description in
            VStack(alignment: .leading, spacing: 12) {
              Text(description.title)
                .foregroundStyle(Color.ds.text.neutral.quiet)
                .fixedSize(horizontal: false, vertical: true)
              if let link = description.link {
                Button(link.label) {
                  openURL(link.url)
                }
                .buttonStyle(.externalLink)
                .controlSize(.mini)
                .accessibilityAddTraits(.isLink)
                .accessibilityRemoveTraits(.isButton)
              }
            }
          }
        }
        .font(Device.isMac ? .subheadline : .footnote)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(
      Color.ds.container.agnostic.neutral.supershy
        .onTapGesture {
          toggleCollapse()
        }
    )
    .cornerRadius(4)
  }

  private func toggleCollapse() {
    withAnimation(.spring()) {
      selectedItem = selectedItem == item ? nil : item
    }
  }
}

struct FAQItemView_Previews: PreviewProvider {

  struct Preview: View {
    @State private var selectedItem: FAQItem?

    var body: some View {
      FAQItemView(
        item: FAQItem(
          title: "What is the meaning of life?",
          description: .init(
            title: "description",
            link: .init(
              label: "Link",
              url: URL(string: "_")!
            )
          )
        ),
        selectedItem: $selectedItem
      )
    }
  }

  static var previews: some View {
    Preview()
  }
}
