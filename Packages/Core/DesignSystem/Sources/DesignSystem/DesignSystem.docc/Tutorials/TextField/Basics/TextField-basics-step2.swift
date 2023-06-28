import SwiftUI
import DesignSystem

struct MyView: View {
    @State private var firstname = ""

    var body: some View {
        DS.TextField(
            "Firstname",
            text: $firstname
        )
    }
}
