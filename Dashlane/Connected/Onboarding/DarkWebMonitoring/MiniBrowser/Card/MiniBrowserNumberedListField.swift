import DesignSystem
import SwiftUI
import UIDelight
import UIComponents

struct MiniBrowserNumberedListField: View {

    @Environment(\.sizeCategory) var sizeCategory

    let number: Int
    let content: String
    let highlightedContent: String?

    init(number: Int, content: String, highlightedContent: String? = nil) {
        self.number = number
        self.content = content
        self.highlightedContent = highlightedContent
    }

    var body: some View {
        HStack(alignment: .top) {
            Text(String(number))
                .foregroundColor(Color(asset: FiberAsset.dwmDashGreen01))
                .font(.custom(GTWalsheimPro.bold.name, size: 16, relativeTo: .callout))
                .frame(width: sizeCategory.isAccessibilityCategory ? 64 : 32, height: sizeCategory.isAccessibilityCategory ? 64 : 32, alignment: .center)
                .background(Circle().foregroundColor(Color.white))
            Group {
                if let highlight = highlightedContent {
                    PartlyModifiedText(text: content, toBeModified: highlight, toBeModifiedModifier: { $0.foregroundColor(Color.white) })
                } else {
                    Text(content)
                }
            }
            .font(.footnote)
            .foregroundColor(.ds.text.inverse.quiet)
            .padding(.leading, 12.0)
            .fixedSize(horizontal: false, vertical: true)
        }.padding(.bottom, 24.0)
    }
}

struct MiniBrowserNumberedListField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            VStack(alignment: .leading) {
                MiniBrowserNumberedListField(number: 1, content: "We just sent you to pinterest.com\nLog in if you’re not already.")
                MiniBrowserNumberedListField(number: 2, content: "Go to the account Settings to change your password. You can use our Password Generator to make a strong one.")
                MiniBrowserNumberedListField(number: 3, content: "Go back to Dashlane and save your new password. Next time we’ll log you in!")
            }
            .padding()
            .background(Color.ds.container.expressive.brand.catchy.idle)
        }.previewLayout(.sizeThatFits)
    }
}
