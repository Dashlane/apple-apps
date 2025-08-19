import SwiftUI
import UIDelight

struct AutoFillAccessoryView: View {
  @State var domain: String
  @State var email: String

  var onTapAction: () -> Void

  var body: some View {
    passwordButton
      .background(Color.ds.container.expressive.neutral.quiet.active)
      .edgesIgnoringSafeArea(.bottom)
  }

  @ViewBuilder
  private var passwordButton: some View {
    Button(action: onTapAction) {
      VStack(spacing: 0) {
        Text(L10n.Localizable.autoFillDemoAccessoryView(domain))
          .font(.callout)
          .minimumScaleFactor(1)
        Text(email)
          .font(.body)
          .minimumScaleFactor(1)
          .truncationMode(.middle)
      }
    }.buttonStyle(KeyboardAutoFillMockButtonStyle())
  }
}

struct AutoFillAccessoryView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      AutoFillAccessoryView(domain: "netflix.com", email: "_", onTapAction: {})
    }.previewLayout(.sizeThatFits)
  }
}
