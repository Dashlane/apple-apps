import DesignSystem
import SwiftUI
import UIComponents

struct PasswordHealthSummaryView: View {

    @ObservedObject
    var viewModel: PasswordHealthViewModel

    var action: (PasswordHealthView.Action) -> Void

    var body: some View {
        VStack(spacing: 0) {
            gauge

            if !viewModel.enoughDataToHaveAScore {
                addPasswordView
            }

            PasswordHealthSummaryCardsView(summary: viewModel.summary) { kind in
                action(.detailedList(kind))
            }
        }
    }

    private var gauge: some View {
        PasswordHealthGauge(
            value: $viewModel.score,
            label: {
                Text(L10n.Localizable.widgetScoreSubtitle.uppercased())
                    .font(.footnote)
                    .foregroundColor(.ds.text.neutral.quiet)
            }, currentValueLabel: {
                gaugeTitle
                    .font(DashlaneFont.custom(80, .bold).font)
                    .foregroundColor(.ds.text.neutral.catchy)
            }
        )
        .frame(width: 188, height: 188)
        .padding(.top, 44)
    }

    private var gaugeTitle: Text {
        if let score = viewModel.score {
            return Text("\(score)")
        } else {
            return Text("--")
        }
    }

    private var addPasswordView: some View {
        VStack(spacing: 24) {
            Text(addPasswordViewTitle)
                .font(.body)
                .foregroundColor(.ds.text.brand.quiet)
                .multilineTextAlignment(.center)

            RoundedButton(L10n.Localizable.addPassword, action: { action(.addPasswords) })
                .roundedButtonLayout(.fill)
        }
        .padding(.top, 32)
    }

    private var addPasswordViewTitle: String {
        if viewModel.totalCredentials == 0 {
            return L10n.Localizable.passwordHealthEmptyState
        } else if viewModel.credentialsNeededToHaveAScore == 1 {
            return L10n.Localizable.passwordHealthNotEnoughAccountsSingular(viewModel.credentialsNeededToHaveAScore)
        } else {
            return L10n.Localizable.passwordHealthNotEnoughAccountsPlural(viewModel.credentialsNeededToHaveAScore)
        }
    }
}

private extension GridItem {
    static func toolsColumn() -> GridItem {
        GridItem(.flexible(), spacing: 15)
    }
}

struct PasswordHealthSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordHealthSummaryView(viewModel: .mock) { _ in }
    }
}
