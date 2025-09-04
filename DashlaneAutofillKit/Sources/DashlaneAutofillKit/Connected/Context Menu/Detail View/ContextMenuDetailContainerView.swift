import Foundation
import SwiftUI

struct ContextMenuDetailContainerView<Content: View>: View {

  let title: String
  let content: Content

  public init(
    title: String,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.content = content()
  }

  public var body: some View {
    List {
      content
    }
    .listStyle(.ds.insetGrouped)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(Text(title))
    .fieldEditionDisabled()
  }
}
