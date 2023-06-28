import DesignSystem
import SwiftUI
import UIDelight
import UIComponents

struct BreachStaticField: DetailField {
    let title: String
    let text: String

    init(title: String,
         text: String) {
        self.title = title
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.ds.text.neutral.quiet)

            Text(text)
                .font(.footnote)
                .foregroundColor(.ds.text.neutral.catchy)

        }
        .background(Color.ds.container.agnostic.neutral.supershy)
    }

}

struct BreachStaticField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VStack {
                BreachStaticField(title: "Missing password", text: "If you don't remember it, try resetting with \"forgot password\"")
            }
        }.previewLayout(.sizeThatFits)
    }
}
