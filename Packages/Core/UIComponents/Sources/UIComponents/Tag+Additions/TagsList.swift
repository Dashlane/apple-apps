#if canImport(UIKit)
  import SwiftUI
  import DesignSystem

  public struct TagsList: View {

    @ScaledMetric private var spacing = 12

    public struct Element: ExpressibleByStringLiteral {
      let title: String
      let leadingAccessory: Tag.LeadingAccessory?
      let trailingAccessory: Tag.TrailingAccessory?

      public init(
        title: String,
        leadingAccessory: Tag.LeadingAccessory? = nil,
        trailingAccessory: Tag.TrailingAccessory? = nil
      ) {
        self.title = title
        self.leadingAccessory = leadingAccessory
        self.trailingAccessory = trailingAccessory
      }

      public init(stringLiteral value: StringLiteralType) {
        self.init(title: value)
      }
    }

    private let elements: [Element]

    public init(_ elements: [Element]) {
      self.elements = elements
    }

    public var body: some View {
      VWaterfallLayout(spacing: spacing) {
        ForEach(elements, id: \.title) { element in
          Tag(
            element.title,
            leadingAccessory: element.leadingAccessory,
            trailingAccessory: element.trailingAccessory
          )
        }
      }
    }
  }

  struct TagsList_Previews: PreviewProvider {
    static var previews: some View {
      TagsListPreview()
    }
  }
#endif
