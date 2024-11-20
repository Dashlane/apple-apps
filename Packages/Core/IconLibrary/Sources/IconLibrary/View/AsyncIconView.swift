import DesignSystem
import SwiftUI
import UIDelight

public struct AsyncIconView<ContentView: View>: View {
  public typealias RichIconProvider = @Sendable () async throws -> Icon?

  let provider: RichIconProvider
  let content: (Image?, Color?) -> ContentView

  @Environment(\.richIconsEnabled) var richIconsEnabled
  @State var icon: Icon?

  public init(
    provider: @escaping RichIconProvider,
    @ViewBuilder content: @escaping (Image?, Color?) -> ContentView
  ) {
    self.provider = provider
    self.content = content
  }

  public var body: some View {
    content(image, color)
      .task(id: richIconsEnabled) {
        guard richIconsEnabled else {
          icon = nil
          return
        }
        icon = try? await provider()
      }
  }

  private var image: Image? {
    return (icon?.image).flatMap(Image.init(uiImage:))
  }

  private var color: Color? {
    return (icon?.color).flatMap(Color.init(uiColor:))
  }
}

public struct EnableIconEnvironmentKey: EnvironmentKey {
  public static let defaultValue: Bool = true
}

extension EnvironmentValues {
  public var richIconsEnabled: Bool {
    get { self[EnableIconEnvironmentKey.self] }
    set { self[EnableIconEnvironmentKey.self] = newValue }
  }
}

#Preview("w/ image") {
  AsyncIconView {
    Icon(image: UIImage(systemName: "person.fill"), color: .red)
  } content: { image, color in
    if let image {
      Thumbnail.login(image)
        .foregroundStyle(color ?? .primary)
    } else {
      Text("Placeholder")
    }
  }
}
