import SwiftUI

public struct ObfuscatedDisplayField<Content: View, Actions: View>: View {
  @State private var isRevealed = false

  private let label: String
  private let contentProvider: (Bool) -> Content
  private let actionsProvider: () -> Actions

  public init(
    _ label: String,
    @ViewBuilder content: @escaping (Bool) -> Content,
    @ViewBuilder actions: @escaping () -> Actions
  ) {
    self.label = label
    self.contentProvider = content
    self.actionsProvider = actions
  }

  public var body: some View {
    DisplayField(label) {
      contentProvider(!isRevealed)
    } actions: {
      actionsProvider()
      DS.FieldAction.RevealSecureContent(reveal: $isRevealed)
    }
  }
}

private struct PreviewContent: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    List {
      ObfuscatedDisplayField("Obfuscated Data") { obfuscated in
        if obfuscated {
          Text("••••••••••")
            .monospaced()
        } else {
          Text(
            AttributedString.passwordAttributedString(
              from: "_",
              with: dynamicTypeSize)
          )
        }
      } actions: {
        DS.FieldAction.CopyContent {
        }
      }
    }
  }
}

#Preview {
  PreviewContent()
}
