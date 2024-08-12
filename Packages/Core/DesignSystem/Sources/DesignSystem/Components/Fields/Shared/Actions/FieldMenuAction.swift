import SwiftUI

public struct FieldMenuAction<Content: View>: View {
  private let title: String
  private let image: Image
  private let content: Content

  public init(_ title: String, image: Image, @ViewBuilder content: () -> Content) {
    self.title = title
    self.image = image
    self.content = content()
  }

  public var body: some View {
    Menu(
      content: { content },
      label: {
        Label {
          Text(verbatim: title)
        } icon: {
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.tint)
        }
      }
    )
  }
}

private struct PreviewContent: View {
  @ScaledMetric private var dimension = 20

  var body: some View {
    FieldMenuAction("More", image: .ds.action.more.outlined) {
      Button(
        action: {},
        label: {
          Label(title: { Text("Undo") }, icon: { Image.ds.action.undo.outlined })
        }
      )
      Button(
        action: {},
        label: {
          Label(title: { Text("Search") }, icon: { Image.ds.action.search.outlined })
        }
      )
      Button(
        action: {},
        label: {
          Label(title: { Text("Sort") }, icon: { Image.ds.action.sort.outlined })
        }
      )
    }
    .frame(height: dimension)
    .background(.red.opacity(0.2))
  }
}

#Preview {
  PreviewContent()
}
