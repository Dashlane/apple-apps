import Foundation
import SwiftUI

struct RecoveryCodeRowView<Content: View>: View {

    let code: String
    let index: Int
    let action: () -> Void

    let imageContent: Content

    init(code: String,
         index: Int,
         action: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        self.code = code
        self.index = index
        self.action = action
        self.imageContent = content()
    }

    var body: some View {
        Button(action: action, label: {
            HStack {
                Text(String(index+1))
                    .foregroundColor(Color(asset: AuthenticatorAsset.secondaryText))
                    .font(.caption)
                    .frame(minWidth: 13, alignment: .trailing)

                Rectangle()
                    .foregroundColor(Color(asset: AuthenticatorAsset.secondaryText))
                    .frame(width: 1)
                    .opacity(0.3)

                Text(code.trimmingCharacters(in: CharacterSet.whitespaces))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(GTWalsheimPro.regular.name, size: 14, relativeTo: .body))
                    .foregroundColor(.accentColor)

                imageContent
            }.padding(10)
            .background(Color(asset: AuthenticatorAsset.codeSectionBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        })
    }
}
