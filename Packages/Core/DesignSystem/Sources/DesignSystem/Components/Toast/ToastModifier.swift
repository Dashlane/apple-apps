import SwiftUI

extension View {
  public func toasterOn(offsetX: Double = 0) -> some View {
    self.modifier(ToastModifier(offsetX: offsetX))
  }
}

struct ToastContent {
  let date: Date = .now
  let view: AnyView
}

struct ToastModifier: ViewModifier {
  @State
  var currentContent: ToastContent?

  let offsetX: Double

  func body(content: Content) -> some View {
    content
      .environment(
        \.toast,
        ToastAction { view in
          currentContent = ToastContent(view: view)
        }
      )
      .overlay(alignment: .top) {
        ToastOverlay(currentContent: $currentContent)
          .frame(maxWidth: .infinity)
          .padding(.leading, offsetX)
      }
  }
}

struct ToastModifier_Previews: PreviewProvider {
  struct ContentView: View {
    @Environment(\.toast)
    var toast

    var body: some View {
      Button("Copy") {
        toast("Copied !", systemImage: "doc.on.doc")
      }

      Button("Delete") {
        toast(ToastLabel("Deleted", systemImage: "trash").style(mood: .danger))
      }

      Button("Too Long") {
        toast(
          ToastLabel(
            "This toast is super long, number of characters is enormous.",
            systemImage: "text.bubble"))
      }
    }
  }

  static var previews: some View {
    List {
      ContentView()
    }
    .toasterOn()
  }
}
