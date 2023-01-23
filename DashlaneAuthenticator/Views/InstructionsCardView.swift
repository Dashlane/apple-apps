import SwiftUI
import UIDelight

struct InstructionsCardView: View {

    let cardContent: [String]
    
    let columns = [
        GridItem(.fixed(32), spacing: 16),
        GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .leading),
    ]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(cardContent.indices, id: \.self) { index in
                if index > 0 {
                    cardSpacer()
                }
                badgeAndContent(index: index + 1, content: cardContent[index])
            }
        }
        .padding()
        .background(.ds.container.agnostic.neutral.supershy)
        .cornerRadius(10)
        .fiberAccessibilityElement(children: .combine)
    }
    
    func badgeAndContent(index: Int, content: String) -> some View {
        Group {
            Circle()
                .foregroundColor(.ds.container.expressive.brand.quiet.idle)
                .frame(width: 32, height: 32)
                .overlay(
                    Text("\(index)")
                        .foregroundColor(.ds.text.brand.standard)
                        .font(.body.weight(.medium)))
            Text(content)
                .font(.body.weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
        }
    }
    
    func cardSpacer() -> some View {
        Group {
            Rectangle()
                .frame(width: 1, height: 31)
                .foregroundColor(.ds.border.neutral.quiet.idle)
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
                    "Third instruction",
                    "Fourth instruction"
                ])
            }
            .padding()
                .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        }
            
    }
}
