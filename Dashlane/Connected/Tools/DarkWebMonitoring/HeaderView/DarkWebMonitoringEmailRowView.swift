import Combine
import CorePersonalData
import DesignSystem
import IconLibrary
import SecurityDashboard
import SwiftUI
import UIDelight

struct DarkWebMonitoringEmailRowView: View {

  @ObservedObject
  var model: DarkWebMonitoringEmailRowViewModel

  var body: some View {
    HStack(spacing: 12) {
      GravatarIconView(model: model.makeGravatarIconViewModel(), isLarge: false)
      VStack(alignment: .leading, spacing: 3) {
        Text(model.title)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .lineLimit(1)
        Text(title(for: model.status))
          .textStyle(.body.reduced.regular)
          .foregroundStyle(titleColor(for: model.status))
      }
      .accessibilityElement(children: .combine)

      Spacer()
      Button(
        action: { model.actionPublisher.send(.deleteEmail(model.title)) },
        label: {
          Image.ds.action.close.outlined
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundStyle(Color.ds.text.neutral.quiet)
        }
      )
      .buttonStyle(PlainButtonStyle())
      .accessibilityLabel(L10n.Localizable.dataleakEmailStopMonitoring(model.title))
      .accessibilityIdentifier("DeleteMonitoredEmailButton")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
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
      List {
        DarkWebMonitoringEmailRowView(model: model)
        DarkWebMonitoringEmailRowView(model: notMonitoredModel)
      }
      .listStyle(.ds.insetGrouped)
    }
    .previewLayout(.sizeThatFits)
  }
}
