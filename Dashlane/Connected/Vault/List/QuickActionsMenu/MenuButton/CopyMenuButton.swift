import DesignSystem
import SwiftUI
import UIDelight

struct CopyMenuButton: View {
    let label: String
    let copyAction: () -> Void

    init(_ label: String, copyAction: @escaping () -> Void) {
        self.label = label
        self.copyAction = copyAction
    }

    var body: some View {
        Button {
            copyAction()
        } label: {
            HStack {
                Text(label)
                Image.ds.action.copy.outlined
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
