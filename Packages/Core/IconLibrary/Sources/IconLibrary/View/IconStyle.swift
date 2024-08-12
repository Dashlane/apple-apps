import DesignSystem
import SwiftUI

public struct IconStyle: ViewModifier {

  let foregroundColor: SwiftUI.Color
  let backgroundColor: SwiftUI.Color
  let sizeType: IconSizeType

  public init(backgroundColor: SwiftUI.Color? = nil, sizeType: IconSizeType) {
    self.foregroundColor = backgroundColor != nil ? .white : .ds.text.brand.quiet
    self.backgroundColor = backgroundColor ?? .ds.container.agnostic.neutral.standard
    self.sizeType = sizeType
  }

  public func body(content: Content) -> some View {
    backgroundColor
      .overlay {
        content
          .foregroundColor(foregroundColor)
      }
      .frame(width: sizeType.size.width, height: sizeType.size.height)
      .modifier(RoundedIcon(sizeType: sizeType))
  }
}

extension View {
  public func iconStyle(sizeType: IconSizeType, backgroundColor: SwiftUI.Color? = nil) -> some View
  {
    self.modifier(IconStyle(backgroundColor: backgroundColor, sizeType: sizeType))
  }
}

struct IconStyle_Previews: PreviewProvider {
  static var previews: some View {

    Group {
      Rectangle()
        .foregroundColor(.red)
        .modifier(
          IconStyle(
            backgroundColor: .blue,
            sizeType: .small))
      Rectangle()
        .foregroundColor(.red)
        .modifier(
          IconStyle(
            backgroundColor: .blue,
            sizeType: .prefilledCredential))

      Rectangle()
        .foregroundColor(.red)
        .modifier(
          IconStyle(
            backgroundColor: .blue,
            sizeType: .large))

    }
    .padding()
    .previewLayout(.sizeThatFits)

  }
}
