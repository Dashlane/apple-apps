import SwiftUI
import UIDelight

public struct AsyncIconView<Placeholder: View, IconView: View>: View {
  public typealias RichIconProvider = @Sendable () async throws -> Icon?
  let animate: Bool
  let provider: RichIconProvider
  let placeholder: Placeholder
  let content: (Image, IconColorSet?) -> IconView

  @State
  var icon: Icon?

  @Environment(\.richIconsEnabled) var richIconsEnabled

  public init(
    animate: Bool = true,
    provider: @escaping RichIconProvider,
    @ViewBuilder content: @escaping (Image, IconColorSet?) -> IconView,
    @ViewBuilder placeholder: () -> Placeholder
  ) {
    self.animate = animate
    self.provider = provider
    self.content = content
    self.placeholder = placeholder()
  }

  public var body: some View {
    ZStack {
      if let icon = icon, let image = icon.image {
        content(Image(appImage: image), icon.colors)
      } else {
        placeholder
      }
    }
    .animationIfNeeded(animate: animate, animation: .easeOut(duration: 0.2), value: icon)
    .task(id: richIconsEnabled) {
      guard richIconsEnabled else {
        icon = nil
        return
      }

      icon = try? await provider()
    }
  }
}

extension View {

  @ViewBuilder
  fileprivate func animationIfNeeded<Value: Equatable>(
    animate: Bool,
    animation: Animation,
    value: Value
  ) -> some View {
    if animate {
      self.animation(animation, value: value)
    } else {
      self
    }
  }
}

public struct EnableIconEnvironmentKey: EnvironmentKey {
  public static var defaultValue: Bool = true
}

extension EnvironmentValues {
  public var richIconsEnabled: Bool {
    get {
      self[EnableIconEnvironmentKey.self]
    }
    set {
      self[EnableIconEnvironmentKey.self] = newValue
    }
  }
}

struct AsyncIconView_Previews: PreviewProvider {
  static let placeholder = Text("placeholder")
  static var previews: some View {
    Group {
      AsyncIconView {
        Icon(image: Asset.logomark.image)
      } content: { image, _ in
        image
          .resizable()
      } placeholder: {
        placeholder
      }
      .previewDisplayName("Image")

      AsyncIconView {
        let colors = IconColorSet(backgroundColor: .red, mainColor: .red, fallbackColor: .red)
        return Icon(image: Asset.logomark.image, colors: colors)
      } content: { image, colors in
        let color = colors?.backgroundColor

        image
          .resizable()
          .background(color.map { SwiftUI.Color($0) })
      } placeholder: {
        placeholder
      }
      .previewDisplayName("Background Colors")

      AsyncIconView {
        return nil
      } content: { image, _ in
        image
          .resizable()
      } placeholder: {
        placeholder
      }
      .previewDisplayName("Placeholder")
    }
    .padding()
    .previewLayout(.sizeThatFits)
  }
}
