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
    ZStack(alignment: .top) {
      if model.shouldShowEmailSection {
        emailListView
          .padding(.top, 80)
          .transition(.move(edge: .top).combined(with: .opacity))
      }

      DarkWebMonitoringEmailHeaderView(
        status: model.status(),
        numberOfEmailsMonitored: model.numberOfEmailsMonitored(),
        isUnrolled: $model.shouldShowEmailSection)

    }
    .background(.ds.container.agnostic.neutral.quiet)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .padding(.horizontal, 16)
    .padding(.top, 16)
  }

  @ViewBuilder
  private var emailListView: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(spacing: 20) {

          ForEach(model.registeredEmails, id: \.email) { email in
            DarkWebMonitoringEmailRowView(model: model.makeRowViewModel(email: email))
          }
          ForEach(model.registeredEmails.count..<model.maxMonitoredEmails, id: \.self) { _ in
            DarkWebMonitoringEmailRowPlaceholderView()
          }
        }
        if model.isMonitoringEnabled {
          addEmailButton
          numberOfSpotsAvailableText
        }
      }
    }
    .frame(idealHeight: 440, maxHeight: 440)
  }

  @ViewBuilder
  private var addEmailButton: some View {
    Button(L10n.Localizable.darkWebMonitoringEmailListViewAddEmail, action: model.addEmail)
      .buttonStyle(.designSystem(.titleOnly))
      .disabled(!model.canAddEmail)
      .opacity(!model.canAddEmail ? 0.4 : 1)
      .padding(.horizontal, 16)
  }

  @ViewBuilder
  private var numberOfSpotsAvailableText: some View {
    HStack {
      MarkdownText(L10n.Localizable.dwmHeaderViewSpotsAvailable(model.availableSpots))
        .font(.body)
        .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity)
  }
}

struct DarkWebMonitoringHeaderView_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      DarkWebMonitoringMonitoredEmailsView(
        model: FakeDarkWebMonitoringMonitoredEmailsViewModel(shouldShowEmailSection: true)
      )
      .background(Color.ds.background.default)

      DarkWebMonitoringMonitoredEmailsView(
        model: FakeDarkWebMonitoringMonitoredEmailsViewModel(shouldShowEmailSection: false)
      )
      .background(Color.ds.background.default)
    }
  }
}
