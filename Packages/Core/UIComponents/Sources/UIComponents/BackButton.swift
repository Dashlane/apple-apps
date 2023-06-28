import SwiftUI
import UIDelight
import DesignSystem
import CoreLocalization

public struct BackButton: View {
    let label: String
    let color: Color
    let action: @MainActor () -> Void

    public init(
        label: String,
        color: Color = .ds.text.neutral.standard,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = label
        self.color = color
        self.action = action
    }

    public var body: some View {
        Button(action: self.action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 13, height: 21)
                    .font(Font.title.weight(.semibold))

                Text(label)
            }
            .offset(x: -6)
            .padding(.trailing, -6)
        }.foregroundColor(color)
    }
}

public extension BackButton {
    init(color: Color = .ds.text.neutral.standard, action: @escaping () -> Void) {
        self.init(label: L10n.Core.kwBack, color: color, action: action)
    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            BackButton(label: "Back") {

            }
            .padding()
            .background(.ds.container.agnostic.neutral.standard)
        }

        .previewLayout(.sizeThatFits)

    }
}
