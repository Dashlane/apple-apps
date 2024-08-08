import Foundation
import SwiftUI
import UIDelight

struct PinButton: View {
  let action: () -> Void
  let fillColor: Color
  let highlightColor: Color
  let title: String

  init(
    action: @escaping () -> Void,
    title: String,
    fillColor: Color = .ds.container.expressive.neutral.quiet.idle,
    highlightColor: Color = .ds.container.expressive.neutral.quiet.hover
  ) {
    self.action = action
    self.title = title
    self.fillColor = fillColor
    self.highlightColor = highlightColor
  }

  var body: some View {
    Button(
      action: {
        self.action()
      },
      label: {
        Text(self.title)
      }
    )
    .frame(maxWidth: 72, maxHeight: 72)
    .buttonStyle(
      PinButtonStyle(
        fillColor: fillColor,
        highlightColor: highlightColor))
  }
}

struct PinButton_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      Group {
        PinButton(action: {}, title: "1")
        PinButton(action: {}, title: "1", fillColor: .yellow)
          .font(.largeTitle)
      }
    }
  }
}

struct PinButtonStyle: ButtonStyle {

  let fillColor: Color
  let highlightColor: Color

  func makeBody(configuration: Self.Configuration) -> some View {
    ZStack {
      Circle()
        .fill(configuration.isPressed ? highlightColor : fillColor)
        .contentShape(Rectangle())
      configuration.label
        .foregroundColor(.ds.text.neutral.standard)
        .lineLimit(1)
    }
  }
}
