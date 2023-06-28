import DesignSystem
import SwiftUI
import UIDelight

struct AutoFillButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.ds.text.neutral.catchy)
            .padding(.top, 9)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color(UIColor.systemGray5) : Color.clear)
    }
}

struct AutoFillButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            Button(action: {}, label: {
                VStack {
                    Text("for google.com — Dashlane")
                        .font(.callout)
                        .minimumScaleFactor(1)
                    Text("_")
                        .font(.body)
                        .minimumScaleFactor(1)
                        .truncationMode(.middle)
                }
            })
            .buttonStyle(AutoFillButtonStyle())
            .background(Color(asset: FiberAsset.autofillDemoAccessoryViewBackground).edgesIgnoringSafeArea(.bottom))
        }.previewLayout(.sizeThatFits)
    }
}
