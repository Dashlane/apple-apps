import Foundation
import SwiftUI

extension Color {
  public static var random: Color {
    return Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1)
    )
  }
}

extension View {

  public func debugBackgroundColor() -> some View {
    self.background(Color.random)
  }

  public func debugForegroundColor() -> some View {
    self.foregroundColor(Color.random)
  }
}
