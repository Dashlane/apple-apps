import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import VaultKit

struct PasswordHealthView: View {

  enum Action {
    case addPasswords
    case detailedList(PasswordHealthKind)
    case credentialDetail(Credential)
  }

  @StateObject
  var viewModel: PasswordHealthViewModel

  var action: (Action) -> Void

  init(
    viewModel: @escaping @autoclosure () -> PasswordHealthViewModel,
    action: @escaping (Action) -> Void
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.action = action
  }

  var body: some View {
    landingView
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .navigationTitle(L10n.Localizable.identityDashboardTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          UserSpaceSwitcher(model: viewModel.userSpaceSwitcherViewModelFactory.make())
        }
      }
      .reportPageAppearance(.toolsPasswordHealthOverview)
  }

  @ViewBuilder
  private var landingView: some View {
    switch viewModel.viewState {
    case .loading:
      EmptyView()
    case .intro:
      introView
    case .summary:
      summaryView
    }
  }

  @ViewBuilder
  private var introView: some View {
    ToolIntroView(
      icon: ExpressiveIcon(.ds.feature.passwordHealth.outlined),
      title: CoreL10n.PasswordHealthIntro.title
    ) {
      FeatureCard {
        FeatureRow(
          asset: ExpressiveIcon(.ds.item.login.outlined),
          title: CoreL10n.PasswordHealthIntro.subtitle1,
          description: CoreL10n.PasswordHealthIntro.description1
        )

        FeatureRow(
          asset: ExpressiveIcon(.ds.tip.outlined),
          title: CoreL10n.PasswordHealthIntro.subtitle2,
          description: CoreL10n.PasswordHealthIntro.description2
        )

        FeatureRow(
          asset: ExpressiveIcon(.ds.healthPositive.outlined),
          title: CoreL10n.PasswordHealthIntro.subtitle3,
          description: CoreL10n.PasswordHealthIntro.description3
        )
      }

      Button {
        action(.addPasswords)
      } label: {
        Label(CoreL10n.PasswordHealthIntro.cta, icon: .ds.arrowRight.outlined)
      }
      .buttonStyle(.designSystem(.iconTrailing(.sizeToFit)))
    }
  }

  @ViewBuilder
  private var summaryView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        PasswordHealthSummaryView(viewModel: viewModel, action: action)

        if !viewModel.isFrozen {
          ForEach(viewModel.summaryListViewModels, id: \.kind) { viewModel in
            PasswordHealthListView(
              viewModel: viewModel,
              action: action
            )
          }
        } else {
          Infobox(CoreL10n.frozenAccountTitle, description: CoreL10n.frozenAccountMessage) {
            Button(CoreL10n.frozenAccountAction) {
              viewModel.displayPaywall()
            }
          }
          .style(mood: .danger)
          .padding(.top, 16)
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
    }
  }
}

struct PasswordHealthView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordHealthView(viewModel: .mock) { _ in }
  }
}
