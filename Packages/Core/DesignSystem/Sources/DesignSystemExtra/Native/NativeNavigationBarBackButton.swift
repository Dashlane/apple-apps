import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight

public struct NativeNavigationBarBackButton: View {
  let label: String
  let action: @MainActor () -> Void

  @ScaledMetric private var chevronSize: CGFloat = 11

  public init(
    _ label: String? = nil,
    action: @escaping @MainActor () -> Void
  ) {
    self.label = label ?? CoreL10n.kwBack
    self.action = action
  }

  public var body: some View {
    Button(action: self.action) {
      HStack(spacing: 9) {
        Image(systemName: "chevron.left")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: chevronSize)
          .font(Font.title.weight(.semibold))

        Text(label)
      }
      .offset(x: -6)
      .padding(.trailing, -6)
    }
  }
}

private struct PreviewContent<C: View>: View {
  @ViewBuilder var content: () -> C

  var body: some View {
    NavigationStack {
      Color.clear
        .navigationDestination(isPresented: .constant(true), destination: content)
    }
    .frame(height: 50)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  VStack {
    PreviewContent {
      Color.clear
        .navigationTitle("Custom back button")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButton {}
    }
    PreviewContent {
      Color.clear
        .navigationTitle("Native back button")
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}
