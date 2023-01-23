import SwiftUI
import UIDelight

struct ToastLabel: View {
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
        self.text = Text(text).font(.body.weight(.medium))
        self.accessibilityAnnouncement = accessibilityAnnouncement ?? text
        self.image = Image(systemName: systemImage)
    }

    init(_ text: String, accessibilityAnnouncement: String? = nil, image: Image? = nil) {
        self.text = Text(text).font(.body.weight(.medium))
        self.accessibilityAnnouncement = accessibilityAnnouncement ?? text
        self.image = image
    }

    var body: some View {
        HStack(alignment: .center) {
            if let image {
                image
                    .scaleEffect(x: showImage ? 1 : 0.6, y: showImage ? 1 : 0.6, anchor: .trailing)
                    .accessibilityHidden(true)
            }
            text
                .scaleEffect(x: showImage ? 1 : 0.9, y: showImage ? 1 : 0.9, anchor: .leading)
        }
        .fiberAccessibilityAnnouncement(accessibilityAnnouncement)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.46).delay(0.2)) {
                showImage = true
            }
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
