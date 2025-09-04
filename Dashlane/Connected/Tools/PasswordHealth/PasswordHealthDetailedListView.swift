import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

struct PasswordHealthDetailedListView: View {

  @StateObject
  var viewModel: PasswordHealthDetailedListViewModel
  let action: (PasswordHealthView.Action) -> Void

  init(
    viewModel: @escaping @autoclosure () -> PasswordHealthDetailedListViewModel,
    action: @escaping (PasswordHealthView.Action) -> Void
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.action = action
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(headline)
        .textStyle(.title.section.medium)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.leading)
        .padding(.top, 16)
        .padding(.horizontal, 16)

      ScrollView {
        PasswordHealthListView(viewModel: viewModel.listViewModel, action: action)
          .padding(.horizontal, 16)
          .padding(.bottom, 16)
      }
    }
    .reportPageAppearance(viewModel.kind.pageEvent)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .navigationTitle(navigationTitle)
    .navigationBarTitleDisplayMode(.inline)
  }

  private var navigationTitle: String {
    if viewModel.credentialsCount == 1 {
      return L10n.Localizable.passwordHealthDetailedListTitleSingular(viewModel.kind.title)
    } else {
      return L10n.Localizable.passwordHealthDetailedListTitlePlural(viewModel.kind.title)
    }
  }

  private var headline: String {
    if viewModel.credentialsCount == 1 {
      return viewModel.kind.singularHeadline
    } else {
      return viewModel.kind.pluralHeadline(count: viewModel.credentialsCount)
    }
  }
}

extension PasswordHealthKind {
  fileprivate var singularHeadline: String {
    switch self {
    case .weak:
      return L10n.Localizable.passwordHealthDetailedWeakListHeadlineSingular
    case .reused:
      return L10n.Localizable.passwordHealthDetailedReusedListHeadlineSingular
    case .compromised:
      return L10n.Localizable.passwordHealthDetailedCompromisedListHeadlineSingular
    default:
      assertionFailure("No detail for other kinds")
      return ""
    }
  }

  fileprivate func pluralHeadline(count: Int) -> String {
    switch self {
    case .weak:
      return L10n.Localizable.passwordHealthDetailedWeakListHeadlinePlural(count)
    case .reused:
      return L10n.Localizable.passwordHealthDetailedReusedListHeadlinePlural(count)
    case .compromised:
      return L10n.Localizable.passwordHealthDetailedCompromisedListHeadlinePlural(count)
    default:
      assertionFailure("No detail for other kinds")
      return ""
    }
  }
}

struct PasswordHealthDetailedListView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordHealthDetailedListView(viewModel: .mock) { _ in }
  }
}
