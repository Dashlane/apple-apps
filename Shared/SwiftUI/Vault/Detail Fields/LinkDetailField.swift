import SwiftUI
import CorePersonalData
import UIDelight

struct LinkDetailField: DetailField {
    let title: String
    var onTap: (() -> Void)

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapWithFeedback {
            self.onTap()
        }
    }
}

struct LinkDetailField_Previews: PreviewProvider {
    static var previews: some View {
        LinkDetailField(title: "website", onTap: {})
    }
}
