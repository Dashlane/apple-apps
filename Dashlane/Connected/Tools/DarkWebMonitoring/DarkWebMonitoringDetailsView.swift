import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight

struct DarkWebMonitoringDetailsView: View {

  @ObservedObject
  var model: DarkWebMonitoringDetailsViewModel

  @State private var showConfirmAlert: Bool = false

  var body: some View {
    List {
      Section {
        detailView
      } header: {
        headerView
      }

      ourAdviceSection
    }
    .safeAreaInset(edge: .bottom) {
      Button {
        showConfirmAlert.toggle()
      } label: {
        Text(L10n.Localizable.dwmDeleteAlertCta)
          .fixedSize(horizontal: true, vertical: false)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .warning, intensity: .supershy)
      .background(Color.ds.background.alternate)
    }
    .listStyle(.ds.insetGrouped)
    .confirmationDialog(
      L10n.Localizable.dwmDetailViewDeleteConfirmTitle,
      isPresented: $showConfirmAlert,
      actions: {
        Button(CoreL10n.kwDelete) {
          confirmDelete()
        }
      }
    )
    .reportPageAppearance(.toolsDarkWebMonitoringAlert)
  }

  @ViewBuilder
  private var headerView: some View {
    VStack(alignment: .center, spacing: 10) {
      BreachIconView(model: model.breachViewModel.iconViewModel)
        .controlSize(.large)
      Text(model.breachViewModel.url.displayDomain)
        .textStyle(.title.block.medium)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(L10n.Localizable.dwmDetailViewSubtitle)
        .textStyle(.title.block.small)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 8)
    .textCase(nil)
  }

  @ViewBuilder
  private var detailView: some View {
    textField(
      title: L10n.Localizable.dwmDetailViewBreachDate,
      text: model.breachViewModel.displayDate)

    if let email = model.breachViewModel.email {
      textField(title: L10n.Localizable.dwmDetailViewEmailAffected, text: email)
    }

    if let leakedData = model.breachViewModel.displayLeakedData {
      textField(title: L10n.Localizable.dwmDetailViewOtherDataAffected, text: leakedData)
    }
  }

  private var ourAdviceSection: some View {
    guard let advice = model.advice else { return EmptyView().eraseToAnyView() }
    return DarkWebMonitoringAdviceSection(advice: advice).eraseToAnyView()
  }

  private func textField(title: String, text: String) -> some View {
    DarkWebMonitoringDetailFieldView(title: title, text: text)
  }

  private func confirmDelete() {
    guard let breach = model.breachViewModel.simplifiedBreach else { return }
    model.actionPublisher?.send(.deleteAndPop(breach))
  }
}

#Preview {
  DarkWebMonitoringDetailsView(model: .fake())
}
