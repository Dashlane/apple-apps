import DesignSystem
import Lottie
import SwiftUI
import UIComponents
import UIDelight

struct M2WStartView: View {

    enum Action {
        case didTapSkip
        case didTapConnect
    }

    @Environment(\.colorScheme)
    private var colorScheme

    let completion: (Action) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            mainContent

            Spacer()

            ctaButton
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .navigationBarBackButtonHidden(true)
        .navigationBarStyle(.transparent)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { completion(.didTapSkip) }, title: L10n.Localizable.m2WStartScreenSkip)
                .foregroundColor(.ds.text.brand.standard)
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack {
            Text(L10n.Localizable.m2WStartScreenTitle)
                .frame(maxWidth: 400)
                .font(DashlaneFont.custom(28, .medium).font)
                .foregroundColor(.ds.text.neutral.catchy)
                .multilineTextAlignment(.center)

            Spacer()
                .frame(height: 16)

            LottieView(.m2WStartScreen)
                .frame(height: 122)
                .padding(.horizontal, 32)

            Spacer()
                .frame(height: 16)

            Text(L10n.Localizable.m2WStartScreenSubtitle)
                .frame(maxWidth: 400)
                .font(.body.weight(.light))
                .foregroundColor(.ds.text.neutral.standard)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }

    @ViewBuilder
    private var ctaButton: some View {
        RoundedButton(L10n.Localizable.m2WStartScreenCTA, action: { completion(.didTapConnect) })
            .roundedButtonLayout(.fill)
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
    }
}
