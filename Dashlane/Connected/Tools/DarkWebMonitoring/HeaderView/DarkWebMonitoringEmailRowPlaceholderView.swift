import Foundation
import SwiftUI
import UIDelight

struct DarkWebMonitoringEmailRowPlaceholderView: View {

    let example = "_"

    var body: some View {
        HStack {
            placeholder
            Text(example)
                .font(.body)
                .foregroundColor(.ds.text.neutral.quiet)
                .padding(.leading, 16)
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color.clear)
        .frame(maxWidth: .infinity)
    }

    private var placeholder: some View {
        ContactsPlaceholderIconView(title: example, isLarge: false)
    }
}

struct DarkWebMonitoringEmailRowPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            DarkWebMonitoringEmailRowPlaceholderView()
        }.previewLayout(.sizeThatFits)
    }
}
