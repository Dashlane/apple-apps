import Foundation
import SwiftUI
import DesignSystem
import UIComponents

struct TwoFARecoverySetupView: View {

    let completion: () -> Void

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ScrollView {
            mainView
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(L10n.Localizable.twofaStepsNavigationTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButton(action: dismiss.callAsFunction)
                    }
                }
                .navigationBarBackButtonHidden(true)
        }
        .overlay(overlayButton)
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Localizable.twofaStepsCaption("2", "3"))
                .foregroundColor(.ds.text.neutral.quiet)
                .font(.callout)
            Text(L10n.Localizable.twofaRecoverySetupTitle)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 28,
                              relativeTo: .title)
                    .weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
            Text(L10n.Localizable.twofaRecoverySetupSubtitle)
                .foregroundColor(.ds.text.neutral.standard)
                .padding(.top, 8)
            infoView
                .padding(.top, 24)
            Spacer()

        }
        .padding(.all, 24)
    }

    var infoView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(L10n.Localizable.twofaRecoverySetupHeader)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.ds.text.neutral.catchy)
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    Image(asset: FiberAsset.successStepper)
                    Text(L10n.Localizable.twofaRecoverySetupMessage1)
                }

                HStack(alignment: .top, spacing: 14) {
                    Image(asset: FiberAsset.successStepper)
                    Text(L10n.Localizable.twofaRecoverySetupMessage2)
                }
            }
            .foregroundColor(.ds.text.neutral.catchy)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.ds.container.agnostic.neutral.quiet)
        )
    }

    var overlayButton: some View {
        VStack {
            Spacer()
            RoundedButton(L10n.Localizable.twofaRecoverySetupCta, action: completion)
                .roundedButtonLayout(.fill)
        }.padding(24)
    }
}

struct TwoFARecoverySetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TwoFARecoverySetupView(completion: {})
        }
    }
}
