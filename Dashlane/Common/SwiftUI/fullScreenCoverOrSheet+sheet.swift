import SwiftTreats
import SwiftUI

extension View {

  @ViewBuilder
  func fullScreenCoverOrSheet<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    if Device.is(.pad, .mac, .vision) {
      sheet(isPresented: isPresented, content: content)
    } else {
      fullScreenCover(isPresented: isPresented, content: content)
    }
  }

  @ViewBuilder
  func fullScreenCoverOrSheet<Content: View, Item: Identifiable>(
    item: Binding<Item?>,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
    if Device.is(.pad, .mac, .vision) {
      sheet(item: item, content: content)
    } else {
      fullScreenCover(item: item, content: content)
    }
  }
}
