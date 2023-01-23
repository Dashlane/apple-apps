import SwiftUI
import UIDelight

struct BreachPasswordGeneratorField: DetailField {
    let title: String = ""
    let text: String

    @Environment(\.detailFieldType)
    var fiberFieldType
    
    init(text: String) {
        self.text = text
    }

    var body: some View {
        PasswordText(text: text)
            .font(.body)
            .lineLimit(1)
            .foregroundColor(Color(asset: FiberAsset.mainCopy))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(asset: FiberAsset.cellBackground))
    }
}

struct BreachPasswordGeneratorField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VStack {
                BreachPasswordGeneratorField(text: "_")
            }
        }.previewLayout(.sizeThatFits)
    }
}
