import Foundation
import SwiftUI
import UIDelight

public struct FullScreenScrollView<Content: View>: View {

  let view: Content

  public init(@ViewBuilder _ view: () -> Content) {
    self.view = view()
  }

  public var body: some View {
    GeometryReader { geo in
      ScrollView(showsIndicators: false) {
        self.view
          .frame(minHeight: geo.size.height)
      }
    }
  }
}

struct FullScreenScrollView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(deviceRange: .some([.iPhoneSE])) {
      FullScreenScrollView {
        VStack {
          Text(
            "We’ll search for breaches associated with your email, then help you secure your accounts."
          )
          Spacer()
          Text("CTA")
        }
      }

      FullScreenScrollView {
        VStack {
          Text(
            "We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts."
          )
          Text(
            "We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts."
          )
          Text(
            "We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts."
          )
          Text(
            "We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts."
          )
          Text(
            "We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts.We’ll search for breaches associated with your email, then help you secure your accounts."
          )
          Spacer()
          Text("CTA")
        }
      }
    }
  }
}
