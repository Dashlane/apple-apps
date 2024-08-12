import SwiftUI

extension List {
  @ViewBuilder
  public func detailListStyle() -> some View {
    self.listStyle(InsetGroupedListStyle())
  }
}
