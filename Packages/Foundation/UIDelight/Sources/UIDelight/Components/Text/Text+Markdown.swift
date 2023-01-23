import SwiftUI

public struct MarkdownText: View {
    private let attributedText: AttributedString

    public init(_ markdown: String) {
        self.attributedText = (try? AttributedString(markdown: markdown)) ?? AttributedString(markdown)
    }

    public var body: some View {
        Text(attributedText)
    }
}

struct MarkdownText_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownText("Text with **bold** area")
    }
}
