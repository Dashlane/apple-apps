import Combine
import CorePersonalData
import DesignSystem
import SecurityDashboard
import SwiftUI
import UIComponents
import UIDelight

struct DarkWebMonitoringMonitoredEmailsView<
  Model: DarkWebMonitoringMonitoredEmailsViewModelProtocol
>: View {

  @StateObject
  var model: Model

  @State
  private var height: CGFloat?

  init(model: @autoclosure @escaping () -> Model) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    Section {
      DarkWebMonitoringEmailHeaderView(
        status: model.status(),
        numberOfEmailsMonitored: model.numberOfEmailsMonitored(),
        isUnrolled: $model.shouldShowEmailSection)
      if model.shouldShowEmailSection {
        emailListView
          .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
  }

  @ViewBuilder
  private var emailListView: some View {
    ForEach(model.registeredEmails, id: \.email) { email in
      let hideSeparator =
        email == model.registeredEmails.last
        && model.registeredEmails.count == model.maxMonitoredEmails
      DarkWebMonitoringEmailRowView(model: model.makeRowViewModel(email: email))
        .listRowSeparator(hideSeparator ? .hidden : .visible)
    }
    ForEach(model.registeredEmails.count..<model.maxMonitoredEmails, id: \.self) { index in
      DarkWebMonitoringEmailRowPlaceholderView()
        .listRowSeparator(index == (model.maxMonitoredEmails - 1) ? .hidden : .visible)
    }

    VStack(spacing: 16) {
      if model.isMonitoringEnabled {
        addEmailButton
        numberOfSpotsAvailableText
      }
    }
    .frame(maxWidth: .infinity)

  }

  @ViewBuilder
  private var addEmailButton: some View {
    Button(L10n.Localizable.darkWebMonitoringEmailListViewAddEmail, action: model.addEmail)
      .buttonStyle(.designSystem(.titleOnly))
      .disabled(!model.canAddEmail)
      .opacity(!model.canAddEmail ? 0.4 : 1)
  }

  @ViewBuilder
  private var numberOfSpotsAvailableText: some View {
    HStack {
      MarkdownText(L10n.Localizable.dwmHeaderViewSpotsAvailable(model.availableSpots))
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .padding(.bottom, 12)
    }
    .frame(maxWidth: .infinity)
  }
}

struct DarkWebMonitoringHeaderView_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      List {
        DarkWebMonitoringMonitoredEmailsView(
          model: FakeDarkWebMonitoringMonitoredEmailsViewModel(shouldShowEmailSection: true)
        )
        .background(Color.ds.background.default)
      }
      .listStyle(.ds.insetGrouped)

      List {
        DarkWebMonitoringMonitoredEmailsView(
          model: FakeDarkWebMonitoringMonitoredEmailsViewModel(shouldShowEmailSection: false)
        )
        .background(Color.ds.background.default)
      }
      .listStyle(.ds.insetGrouped)
    }
  }
}
