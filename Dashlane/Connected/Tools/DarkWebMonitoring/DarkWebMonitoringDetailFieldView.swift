import SwiftUI
import UIDelight

struct DarkWebMonitoringDetailFieldView: View {
    let title: String
    let text: String

    init(title: String,
         text: String) {
        self.title = title
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.footnote)
                .foregroundColor(Color(asset: FiberAsset.grey01))

            Text(text)
                .font(.body)
                .foregroundColor(Color(asset: FiberAsset.mainCopy))

        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(asset: FiberAsset.cellBackground))
    }
}

struct DarkWebMonitoringDetailFieldView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VStack {
                DarkWebMonitoringDetailFieldView(title: "Breach email", text: "_")
                DarkWebMonitoringDetailFieldView(title: "Breach data", text: "long content that could take up the whole screen ?")
                DarkWebMonitoringDetailFieldView(title: "Breach data", text: DateFormatter.mediumDateFormatter.string(from: Date()))
            }

        }

    }
}
