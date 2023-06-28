import SwiftUI
import DesignSystem

struct MyView: View {
    @State private var masterPassword = ""

    var body: some View {
        DS.PasswordField(
            "Master Password",
            placeholder: "Enter your master password",
            text: $masterPassword
        )
    }
}
