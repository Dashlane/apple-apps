import SwiftUI

public struct NavigationBarAddIcon: View {

  public init() {}

  public var body: some View {
    Image(systemName: "plus.circle.fill")
      .resizable()
      .frame(width: 22, height: 22)
      .padding(4)
      .foregroundStyle(Color.ds.text.brand.standard)
      .accessibilityIdentifier("plus")
  }
}
