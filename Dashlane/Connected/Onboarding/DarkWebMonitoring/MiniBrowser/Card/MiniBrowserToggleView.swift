import SwiftUI
import UIDelight

struct MiniBrowserToggleView: View {
    let title: String

    @Binding
    var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(Color.white)
                .font(.body)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct MiniBrowserToggleView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            MiniBrowserToggleView(title: "Letters (e.g. Aa)Letters (e.g. Aa)",
                                  isOn: .constant(true)).background(Color(asset: FiberAsset.mainGreen))
        }
    }
}
