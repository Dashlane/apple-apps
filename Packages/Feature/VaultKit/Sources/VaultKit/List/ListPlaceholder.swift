import DesignSystem
import SwiftUI

public struct ListPlaceholder<Accessory: View>: View {
  let icon: Image
  let title: String
  let description: String
  let accessory: Accessory

  public init(
    icon: Image, title: String, description: String, @ViewBuilder accessory: () -> Accessory
  ) {
    self.icon = icon
    self.title = title
    self.description = description
    self.accessory = accessory()
  }

  public var body: some View {
    VStack(spacing: 24) {
      ExpressiveIcon(icon)
        .style(mood: .neutral, intensity: .quiet)
        .controlSize(.large)

      VStack(spacing: 8) {
        Text(title)
          .textStyle(.title.section.medium)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .multilineTextAlignment(.center)

        Text(description)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .multilineTextAlignment(.center)
      }

      accessory
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 5)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

extension ListPlaceholder {
  public init(category: ItemCategory, @ViewBuilder accessory: () -> Accessory) {
    self.init(
      icon: category.icon,
      title: category.placeholderTitle,
      description: category.placeholderDescription,
      accessory: accessory
    )
  }
}

extension ListPlaceholder where Accessory == EmptyView {
  public init(category: ItemCategory) {
    self.init(category: category) {
      EmptyView()
    }
  }

  public init(icon: Image, title: String, description: String) {
    self.init(icon: icon, title: title, description: description) {
      EmptyView()
    }
  }
}

struct ListPlaceholder_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ListPlaceholder(
        icon: ItemCategory.credentials.icon,
        title: ItemCategory.credentials.placeholderTitle,
        description: ItemCategory.credentials.placeholderDescription
      ) {

      }
      ListPlaceholder(category: ItemCategory.credentials)
    }

  }
}
