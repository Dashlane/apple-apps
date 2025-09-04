import SwiftUI

public struct FieldButtonAction: View {
  private let title: String
  private let image: Image
  private let action: @MainActor () -> Void

  public init(_ title: String, image: Image, action: @escaping @MainActor () -> Void) {
    self.title = title
    self.image = image
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Label {
        Text(verbatim: title)
      } icon: {
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
      }
    }
    .accessibilityLabel(title)
  }
}

private struct PreviewContent: View {
  var body: some View {
    VStack(spacing: 10) {
      FieldButtonAction("Delete", image: .ds.action.delete.filled, action: {})
        .frame(height: 20)
        .background(.red.opacity(0.2))

      FieldButtonAction(
        "Password Generator",
        image: .ds.feature.passwordGenerator.outlined,
        action: {}
      )
      .frame(height: 20)
      .background(.red.opacity(0.2))

      FieldButtonAction(
        "Account Settings",
        image: .ds.accountSettings.outlined,
        action: {}
      )
      .frame(height: 20)
      .background(.red.opacity(0.2))
    }
  }
}

#Preview {
  PreviewContent()
}
