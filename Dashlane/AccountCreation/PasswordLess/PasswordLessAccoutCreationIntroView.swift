import SwiftUI
import DesignSystem
import CoreLocalization

struct PasswordLessAccountCreationIntroView: View {
    let l10n = L10n.Localizable.PasswordlessAccountCreation.Intro.self
    let completion: () -> Void

    @State
    var isLearnMoreDisplayed: Bool = false

    var body: some View {
        VStack {
            VStack(spacing: 24) {
                description
                infoBox
            }
            Spacer()
            actions
        }
        .padding(.top, 51)
        .padding(.bottom, 35)
        .padding(.horizontal, 24)
        .loginAppearance()
        .navigationTitle(l10n.navigationTitle)
        .safariSheet(isPresented: $isLearnMoreDisplayed, url: URL(string: "_")!)
    }

    var description: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(l10n.title)
                .textStyle(.specialty.brand.small)
            Text(l10n.message)
                .textStyle(.body.reduced.regular)
        }
    }

    var infoBox: some View {
        Infobox(title: l10n.infoBox)
            .style(mood: .neutral)
            .controlSize(.small)
    }

    var actions: some View {
        VStack(spacing: 8) {
            RoundedButton(l10n.getStartedButton) {
                completion()
            }
            .style(mood: .brand, intensity: .catchy)
            RoundedButton(l10n.learnMoreButton) {
                isLearnMoreDisplayed = true
            }
            .style(mood: .brand, intensity: .quiet)
        }.roundedButtonLayout(.fill)
    }
}

struct PasswordLessAccoutCreationIntroView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordLessAccountCreationIntroView {

        }
    }
}
