import SwiftUI

struct ActionDetailField: DetailField {
    let title: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action, title: actionTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accentColor(Color(asset: FiberAsset.accentColor))
            .labeled(title)
    }
}

struct ActionDetailField_Previews: PreviewProvider {
    static var previews: some View {
        ActionDetailField(title: "Action", actionTitle: "Do something") {

        }
    }
}
