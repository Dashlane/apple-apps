import DesignSystem
import SwiftUI
import UIDelight

struct CopyMenuButton: View {
    let label: String
    let copyAction: () -> Void
    let icon: ImageAsset

    init(_ label: String,
         icon: ImageAsset = FiberAsset.copyItem,
         copyAction: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.copyAction = copyAction
    }

    var body: some View {
        Button {
            copyAction()
        } label: {
            HStack {
                Text(label)
                icon.swiftUIImage
            }
        }
    }
}

struct CopyMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            CopyMenuButton("Copy info") {}
                .foregroundColor(.ds.text.neutral.catchy)
        }
        .padding()
        .background(Color.ds.background.default)
        .previewLayout(.sizeThatFits)
    }
}
