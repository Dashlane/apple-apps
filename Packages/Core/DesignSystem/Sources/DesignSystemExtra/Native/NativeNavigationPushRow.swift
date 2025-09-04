import SwiftUI

public struct NativeNavigationPushRow: View {
  let title: String
  let action: () -> Void

  public init(title: String, action: @escaping () -> Void) {
    self.title = title
    self.action = action
  }

  public var body: some View {
    HStack {
      Text(title)
        .foregroundStyle(Color.ds.text.neutral.standard)
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundStyle(Color.ds.text.neutral.quiet)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .onTapWithFeedback {
      self.action()
    }
  }
}

#Preview {
  List {
    NativeNavigationPushRow(title: "The Title") {

    }
  }
  .listStyle(.ds.insetGrouped)

}
