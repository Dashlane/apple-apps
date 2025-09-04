import Foundation
import SwiftUI
import UIDelight

public struct SheetLink: View {
  let title: String
  let url: URL

  @State var isPresented: Bool = false

  public init(_ title: String, url: URL) {
    self.title = title
    self.url = url
  }

  public var body: some View {
    Button {
      isPresented = true
    } label: {
      Text(title)
        .underline()
        .font(.headline)
        .foregroundStyle(Color.ds.text.brand.standard)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }
    .safariSheet(isPresented: $isPresented, url: url)
    .fiberAccessibilityRemoveTraits(.isButton)
    .fiberAccessibilityAddTraits(.isLink)
  }
}

#Preview {
  SheetLink("This is a link", url: URL(string: "google.com")!)
}
