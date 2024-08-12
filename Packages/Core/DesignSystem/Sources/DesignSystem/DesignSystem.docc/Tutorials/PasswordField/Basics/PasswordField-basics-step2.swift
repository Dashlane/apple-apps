import DesignSystem
import SwiftUI

struct MyView: View {
  @State private var masterPassword = ""

  var body: some View {
    DS.PasswordField(
      "Master Password",
      text: $masterPassword
    )
  }
}
