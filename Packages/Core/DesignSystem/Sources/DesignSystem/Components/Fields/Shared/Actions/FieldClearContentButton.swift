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
              Text(L10n.Core.accessibilityClearText)
            } icon: {
              Image.ds.action.clearContent.filled
                .resizable()
                .aspectRatio(contentMode: .fit)
            }
          }
        )
        .accessibilityLabel(Text(L10n.Core.accessibilityClearText))
        .style(mood: .neutral)
        .tint(.ds.container.expressive.neutral.catchy.idle)
      }
    }
    .onChange(of: text.wrappedValue) { newValue in
      displayButton(!newValue.isEmpty)
    }
  }

  private func displayButton(_ display: Bool) {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
      displayButton = display
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
