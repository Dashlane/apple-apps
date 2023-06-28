#if canImport(UIKit)

import SwiftUI

public struct LargeHeaderSection<Content: View>: View {

    let title: String
    let content: () -> Content

    private var size: CGFloat {
        return UIFontMetrics.default.scaledValue(for: 20)
    }

    public init(title: String,
                @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    public var body: some View {
        Section(header: newHeader,
                content: content)
    }

    @ViewBuilder
    var newHeader: some View {
        Text(title)
            .font(.system(size: size))
            .fontWeight(.bold)
            .textCase(.none)
            .foregroundColor(.ds.text.neutral.standard)
            .padding(EdgeInsets(top: 0, leading: -16, bottom: 0, trailing: 0))
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity)
    }

}

struct LargeHeaderSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            LargeHeaderSection(title: "Hello, World!") {
                Text("foo")
                Text("42")
            }
        }
    }
}

#endif
