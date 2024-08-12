import SwiftUI

public struct ListItemContentView<Label: View, LeadingAccessory: View>: View {
  @Environment(\.dynamicTypeSize.isAccessibilitySize) private var isAccessibilitySize
  @ScaledMetric private var spacing = 12

  private let label: Label
  private let leadingAccessory: LeadingAccessory

  public init(
    @ViewBuilder label: () -> Label,
    @ViewBuilder leadingAccessory: () -> LeadingAccessory
  ) {
    self.label = label()
    self.leadingAccessory = leadingAccessory()
  }

  public var body: some View {
    HStack(spacing: spacing) {
      if !isAccessibilitySize {
        leadingAccessory
      }
      label
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  ListItemContentView {
    Text("Label")
  } leadingAccessory: {
    Circle()
      .frame(width: 24, height: 24)
      .foregroundStyle(.red)
  }
  .padding(.horizontal)
}
