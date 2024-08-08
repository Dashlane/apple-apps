import Combine
import CorePersonalData
import DesignSystem
import SecurityDashboard
import SwiftUI
import UIDelight
import VaultKit

struct DarkWebMonitoringEmailRowView: View {

  @ObservedObject
  var model: DarkWebMonitoringEmailRowViewModel

  var body: some View {
    HStack {
      GravatarIconView(model: model.makeGravatarIconViewModel(), isLarge: false)
      VStack(alignment: .leading, spacing: 3) {
        Text(model.title)
          .font(.body)
          .foregroundColor(.ds.text.neutral.standard)
        Text(title(for: model.status))
          .font(.footnote)
          .foregroundColor(titleColor(for: model.status))
      }.padding(.leading, 16)
        .accessibilityElement(children: .combine)
      Spacer()
      Button(
        action: { model.actionPublisher.send(.deleteEmail(model.title)) },
        label: {
          Image.ds.action.close.outlined
            .foregroundColor(.ds.text.neutral.quiet)
        }
      )
      .accessibilityLabel(L10n.Localizable.dataleakEmailStopMonitoring(model.title))
      .accessibilityIdentifier("DeleteMonitoredEmailButton")
    }
    .padding(.horizontal, 16)
    .background(Color.clear)
    .frame(maxWidth: .infinity)
  }

  private func title(for status: DataLeakEmail.State) -> String {
    switch status {
    case .active:
      return L10n.Localizable.dataleakEmailStatusActive
    case .pending:
      return L10n.Localizable.darkWebMonitoringVerifyToBeginMonitoring
    case .disabled:
      return L10n.Localizable.dataleakEmailStatusInactive
    }
  }

  private func titleColor(for status: DataLeakEmail.State) -> SwiftUI.Color {
    switch status {
    case .active:
      return .ds.text.neutral.quiet
    case .pending:
      return .ds.text.warning.quiet
    case .disabled:
      return .ds.text.neutral.quiet
    }
  }
}

struct DarkWebMonitoringEmailRowView_Previews: PreviewProvider {

  private static var model = DarkWebMonitoringEmailRowViewModel(
    email: DataLeakEmail(pendingEmail: "_"),
    iconService: IconServiceMock(),
    actionPublisher: .init())

  private static var notMonitoredModel = DarkWebMonitoringEmailRowViewModel(
    email: DataLeakEmail(pendingEmail: "_"),
    iconService: IconServiceMock(),
    actionPublisher: .init())

  static var previews: some View {
    MultiContextPreview {
      VStack {
        DarkWebMonitoringEmailRowView(model: model)
        DarkWebMonitoringEmailRowView(model: notMonitoredModel)
      }
      .background(Color.ds.container.expressive.brand.quiet.idle)
    }
    .previewLayout(.sizeThatFits)
  }
}
