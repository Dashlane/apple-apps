import DesignSystem
import SwiftUI

public struct DetailRowButtonStyle: PrimitiveButtonStyle {
  public enum Mode {
    case `default`
    case destructive

    var color: Color {
      switch self {
      case .`default`:
        return .ds.text.brand.standard
      case .destructive:
        return .red
      }
    }
  }

  let color: Color
  public init(_ mode: Mode = .default) {
    self.color = mode.color
  }

  public func makeBody(configuration: Configuration) -> some View {
    #if targetEnvironment(macCatalyst)
      let buttonStyle = BorderlessButtonStyle()
    #else
      let buttonStyle = DefaultButtonStyle()
    #endif

    Button(action: configuration.trigger) {
      configuration.label
        .foregroundColor(color)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    .buttonStyle(buttonStyle)
  }
}
