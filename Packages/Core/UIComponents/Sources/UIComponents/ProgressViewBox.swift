import DesignSystem
import Foundation
import SwiftUI
import UIDelight

struct LoadingModifier: ViewModifier {

  var isLoading: Bool
  var offset: CGFloat

  func body(content: Content) -> some View {
    ZStack {
      content
      if isLoading {
        Group {
          ProgressView()
            .offset(y: offset)
        }
        .transition(.opacity)
      }
    }
  }

}

public struct ProgressViewBox: View {

  public init() {}

  public var body: some View {
    ProgressView()
      .tint(.ds.text.brand.standard)
      .padding(20)
      .background(.ds.container.agnostic.neutral.quiet)
      .cornerRadius(8)
  }
}

extension View {
  public func loading(isLoading: Bool, loadingIndicatorOffset: Bool = false) -> some View {
    return self.modifier(
      LoadingModifier(isLoading: isLoading, offset: loadingIndicatorOffset ? 75 : 0))
  }
}

struct ActivityIndicatorBox_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      ProgressViewBox()
    }
  }
}
