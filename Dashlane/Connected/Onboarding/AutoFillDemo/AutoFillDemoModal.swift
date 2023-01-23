import SwiftUI
import UIDelight
import UIComponents
import DesignSystem

struct AutoFillDemoModal: View {

    enum Completion {
        case tryDemo
        case returnHome
    }

    public var completion: ((Completion) -> Void)?

    var body: some View {
            VStack(alignment: .center) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(asset: FiberAsset.checklistCheckmark)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .fiberAccessibilityHidden(true)
                        Text(L10n.Localizable.autofillDemoModalTitle)
                            .font(DashlaneFont.custom(20, .medium).font)
                    }

                    Text(L10n.Localizable.autofillDemoModalSubtitle)
                        .lineLimit(3)
                        .font(.callout)
                }
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.01)

                LottieView(.onboardingAutofill)
                    .frame(width: UIScreen.main.bounds.width * 0.4,
                           height: UIScreen.main.bounds.width * 0.4)
                    .padding(.vertical, 8)

                RoundedButton(L10n.Localizable.autofillDemoModalPrimaryAction,
                              action: { completion?(.tryDemo) })
                .roundedButtonLayout(.fill)

                Button(action: { completion?(.returnHome) }, label: {
                    Text(L10n.Localizable.autofillDemoModalSecondaryAction)
                        .foregroundColor(.ds.text.neutral.standard)
                }).buttonStyle(BorderlessActionButtonStyle())

            }
            .padding(26)
            .background(Color(asset: FiberAsset.mainBackground))
    }
}

struct AutoFillDemoModal_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AutoFillDemoModal().previewLayout(.sizeThatFits)
        }
    }
}
