import SwiftUI
import UIDelight

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
                .foregroundColor(Color(asset: FiberAsset.grey01))

            Text(text)
                .font(.footnote)
                .foregroundColor(Color(asset: FiberAsset.mainCopy))

        }
        .background(Color(asset: FiberAsset.cellBackground))
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
