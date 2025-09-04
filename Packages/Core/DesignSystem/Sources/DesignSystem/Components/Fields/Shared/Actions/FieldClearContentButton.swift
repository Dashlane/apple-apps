import CoreLocalization
import SwiftUI

public struct FieldClearContentButton: View {
  @State private var displayButton: Bool
  private let text: Binding<String>

  public init(text: Binding<String>) {
    self.text = text
    _displayButton = .init(initialValue: !text.wrappedValue.isEmpty)
  }

  public var body: some View {
    ZStack {
      if displayButton {
        Button(
          action: { text.wrappedValue = "" },
          label: {
            Label {
              Text(CoreL10n.accessibilityClearText)
            } icon: {
              Image.ds.action.clearContent.filled
                .resizable()
                .aspectRatio(contentMode: .fit)
            }
          }
        )
        .accessibilityLabel(Text(CoreL10n.accessibilityClearText))
        .style(mood: .neutral)
        .tint(.ds.container.expressive.neutral.catchy.idle)
      }
    }
    .onChange(of: text.wrappedValue) { _, newValue in
      displayButton = !newValue.isEmpty
    }
  }
}

private struct PreviewContent: View {
  @State private var text = "Hello World!"

  var body: some View {
    VStack {
      FieldClearContentButton(text: $text)
        .background(.red.opacity(0.2))

      Text(text)
    }
  }
}

#Preview {
  PreviewContent()
}
