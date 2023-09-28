import SwiftUI
import UIDelight

public struct InstructionsCardView: View {

    let cardContent: [String]

    let columns = [
        GridItem(.fixed(32), spacing: 16),
        GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .leading)
    ]

    public init(cardContent: [String]) {
        self.cardContent = cardContent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(cardContent.indices, id: \.self) { index in
                badgeAndContent(index: index + 1, content: cardContent[index])
            }
        }
        .padding(24)
        .background(.ds.container.agnostic.neutral.supershy)
        .cornerRadius(10)
        .fiberAccessibilityElement(children: .combine)
    }

    func badgeAndContent(index: Int, content: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .foregroundColor(.ds.container.expressive.brand.quiet.idle)
                .frame(width: 32, height: 32)
                .overlay(
                    MarkdownText("\(index)")
                        .foregroundColor(.ds.text.brand.standard)
                        .font(.body.weight(.medium)))
            MarkdownText(content)
                .font(.body)
                .foregroundColor(.ds.text.neutral.catchy)
        }
    }

    func cardSpacer() -> some View {
        Group {
            Rectangle()
                .frame(width: 1, height: 31)
                        Text("")
        }
    }
}
struct InstructionsCardView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            ScrollView {
                InstructionsCardView(cardContent: [
                    "First instruction",
                    "Second instruction",
                    "**Third instruction**",
                    "Fourth instruction"
                ])
            }
            .padding()
                .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        }

    }
}
