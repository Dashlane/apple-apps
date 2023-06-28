import SwiftUI
import UIDelight

struct ToastLabel: View {
        @Environment(\.style) private var style

        let text: Text
    let image: Image?
    let accessibilityAnnouncement: String

        @State
    var showImage: Bool = false

        init(_ text: Text, accessibilityAnnouncement: String, systemImage: String) {
        self.text = text
        self.accessibilityAnnouncement = accessibilityAnnouncement
        self.image = Image(systemName: systemImage)
    }

    init(_ text: Text, accessibilityAnnouncement: String, image: Image? = nil) {
        self.text = text
        self.accessibilityAnnouncement = accessibilityAnnouncement
        self.image = image
    }

    init(_ text: String, accessibilityAnnouncement: String? = nil, systemImage: String) {
        self.text = Text(text)
        self.accessibilityAnnouncement = accessibilityAnnouncement ?? text
        self.image = Image(systemName: systemImage)
    }

    init(_ text: String, accessibilityAnnouncement: String? = nil, image: Image? = nil) {
        self.text = Text(text)
        self.accessibilityAnnouncement = accessibilityAnnouncement ?? text
        self.image = image
    }

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if let image {
                image
                    .scaleEffect(x: showImage ? 1 : 0.6, y: showImage ? 1 : 0.6, anchor: .trailing)
                    .accessibilityHidden(true)
                    .font(.system(.body).weight(.medium))
            }
            text
                .textStyle(.body.standard.strong)
                .scaleEffect(x: showImage ? 1 : 0.9, y: showImage ? 1 : 0.9, anchor: .leading)
                .padding(.horizontal, 4)
        }
        .foregroundColor(.contentForegroundColor(for: style))
        .fiberAccessibilityAnnouncement(accessibilityAnnouncement)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.46).delay(0.2)) {
                showImage = true
            }
        }
    }
}

extension Color {
    static func contentForegroundColor(for style: Style) -> Color {
        switch style.mood {
        case .danger:
            return .ds.text.danger.quiet
        default:
            return .ds.text.neutral.catchy
        }
    }
}

struct ToastLabel_Previews: PreviewProvider {
    static var previews: some View {
        ToastLabel("Copied !", systemImage: "doc.on.doc")
            .padding()
            .previewLayout(.sizeThatFits)

        ToastLabel("This toast is super long, number of characters is enormous.", systemImage: "text.bubble")
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
