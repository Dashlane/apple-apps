import SwiftUI

public struct NativeAlert<Content: View, Buttons: View>: View {
  let spacing: CGFloat?
  let content: Content
  let buttons: Buttons
  @State private var isDisplayed: Bool = false

  public init(
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content,
    @ViewBuilder buttons: () -> Buttons
  ) {
    self.spacing = spacing
    self.content = content()
    self.buttons = buttons()
  }

  public var body: some View {
    VStack(spacing: spacing) {
      content

      NativeAlertButtonsStack {
        buttons
      }
    }
    .background(Material.regular)
    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    .opacity(isDisplayed ? 1.0 : 0)
    .frame(width: 270)
    .padding()
    .scaleEffect(isDisplayed ? 1.0 : 1.5)
    .offset(x: 0, y: isDisplayed ? 0 : 300)
    .onAppear {
      withAnimation(.spring(response: 0.404)) {
        self.isDisplayed = true
      }
    }
    .buttonStyle(.nativeAlert)
  }
}

extension NativeAlert where Buttons == EmptyView {
  public init(spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
    self.spacing = spacing
    self.content = content()
    self.buttons = EmptyView()
  }
}

#Preview("With buttons") {
  NativeAlert {
    Text("Do you want to cancel \"Cancel\"")
      .multilineTextAlignment(.center)
      .padding()
  } buttons: {
    Button("Cancel", role: .cancel) {}
    Button("Cancel") {}
  }
}

#Preview("Without buttons") {
  NativeAlert {
    Text("Hello, World!")
      .padding()
  }
}

#Preview("Without buttons") {
  NativeAlert {
    Text("Hello, World!")
      .padding()
  } buttons: {

  }
}

#Preview("Disable/enable") {
  @Previewable @State var isDisabled: Bool = false

  NativeAlert {
    Text("Do you want to cancel \"Cancel\"")
      .multilineTextAlignment(.center)
      .padding()
  } buttons: {
    Button("Toggle") {
      isDisabled.toggle()
    }
    Button("Action") {}
      .disabled(isDisabled)
  }
}
