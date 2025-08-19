import SwiftUI

public enum NativeAlertButtonsLayout {
  case horizontal
  case vertical
}

extension View {
  public func alertButtonsLayout(_ layout: NativeAlertButtonsLayout) -> some View {
    self.environment(\.alertLayout, layout)
  }
}

extension EnvironmentValues {
  @Entry fileprivate var alertLayout: NativeAlertButtonsLayout = .horizontal
}

struct NativeAlertButtonsStack<Content: View>: View {
  var content: Content
  @Environment(\.alertLayout) private var layout: NativeAlertButtonsLayout

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    switch layout {
    case .horizontal:
      _VariadicView.Tree(NativeAlertButtonsHRoot()) {
        content
      }
    case .vertical:
      _VariadicView.Tree(NativeAlertButtonsVRoot()) {
        content
      }
    }
  }
}

private struct NativeAlertButtonsHRoot: _VariadicView.MultiViewRoot {
  func body(children: _VariadicView.Children) -> some View {
    if let last = children.last {
      VStack(spacing: 0) {
        Divider()
        HStack(spacing: 0) {
          ForEach(children.dropLast()) { item in
            item
            Divider()
          }

          last
        }
        .frame(maxHeight: NativeAlertButtonStyle.buttonHeight)
      }
    }
  }

  @ViewBuilder
  private func decorated(_ child: _VariadicView.Children.Element) -> some View {
    child
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

private struct NativeAlertButtonsVRoot: _VariadicView.MultiViewRoot {
  func body(children: _VariadicView.Children) -> some View {
    if let last = children.last {
      VStack(spacing: 0) {
        Divider()

        ForEach(children.dropLast()) { item in
          item
          Divider()
        }

        last
      }
    }
  }
}

#Preview("Horizontal") {
  NativeAlertButtonsStack {
    Button("This") {}
    Button("That") {}
  }
  .buttonStyle(.nativeAlert)
}

#Preview("Vertical") {
  NativeAlertButtonsStack {
    Button("This") {}
    Button("That") {}
  }
  .environment(\.alertLayout, .vertical)
  .buttonStyle(.nativeAlert)
}
