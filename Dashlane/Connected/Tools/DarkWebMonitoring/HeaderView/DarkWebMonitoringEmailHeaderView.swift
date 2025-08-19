import Combine
import DesignSystem
import SecurityDashboard
import SwiftUI
import UIDelight

struct DarkWebMonitoringEmailHeaderView: View {

  let status: DarkWebMonitoringMonitoredEmailsViewModel.Status
  let numberOfEmailsMonitored: Int

  @Binding
  var isUnrolled: Bool

  init(
    status: DarkWebMonitoringMonitoredEmailsViewModel.Status, numberOfEmailsMonitored: Int,
    isUnrolled: Binding<Bool>
  ) {
    self.status = status
    self.numberOfEmailsMonitored = numberOfEmailsMonitored
    self._isUnrolled = isUnrolled
  }

  var body: some View {
    Button(
      action: {
        withAnimation(.spring()) {
          isUnrolled.toggle()
        }
      },
      label: {
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text(emailMonitoredLabel)
              .textStyle(.title.block.medium)
              .foregroundStyle(Color.ds.text.neutral.standard)
            statusBadge
          }
          Spacer()
          chevronIndicator
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .fiberAccessibilityLabel(
          Text(
            "\(emailMonitoredLabel) \(statusText) \(isUnrolled ? L10n.Localizable.accessibilityCollapse : L10n.Localizable.accessibilityExpand)"
          )
        )
        .contentShape(Rectangle())
      }
    )
    .buttonStyle(PlainButtonStyle())
    .accessibilityIdentifier("ExpandMonitoredEmailsButton")
  }

  @ViewBuilder
  private var statusBadge: some View {
    HStack {
      Circle()
        .frame(width: 8, height: 8)
        .foregroundStyle(indicatorColor)
      Text(statusText)
        .textStyle(.body.reduced.regular)
        .foregroundStyle(indicatorColor)
    }
  }

  var emailMonitoredLabel: String {
    switch status {
    case .active, .pending:
      if numberOfEmailsMonitored == 1 {
        return L10n.Localizable.darkWebMonitoringEmailHeaderViewOneEmailMonitored(
          numberOfEmailsMonitored)
      } else {
        return L10n.Localizable.darkWebMonitoringEmailHeaderViewMultiEmailMonitored(
          numberOfEmailsMonitored)
      }
    case .inactive:
      if numberOfEmailsMonitored == 1 {
        return L10n.Localizable.darkWebMonitoringEmailHeaderViewOneEmailInactive(
          numberOfEmailsMonitored)
      } else {
        return L10n.Localizable.darkWebMonitoringEmailHeaderViewMultiEmailInactive(
          numberOfEmailsMonitored)
      }
    }
  }

  private var indicatorColor: Color {
    switch status {
    case .active:
      return .ds.text.positive.quiet
    case .pending:
      return .ds.text.warning.quiet
    case .inactive:
      return .ds.text.danger.quiet
    }
  }

  private var statusText: String {
    switch status {
    case .active:
      return L10n.Localizable.darkWebMonitoringEmailHeaderViewDataLeakMonitoringActive
    case .pending:
      return L10n.Localizable.darkWebMonitoringEmailHeaderViewDataLeakMonitoringOnHold
    case .inactive:
      return L10n.Localizable.darkWebMonitoringEmailHeaderViewDataLeakMonitoringInactive
    }
  }

  @ViewBuilder
  private var chevronIndicator: some View {
    Image(systemName: "chevron.down")
      .resizable()
      .frame(width: 16, height: 10, alignment: .center)
      .foregroundStyle(Color.ds.text.brand.quiet)
      .rotationEffect(Angle.degrees(isUnrolled ? 180 : 0))
      .animation(.easeOut, value: isUnrolled)
  }
}

struct DarkWebMonitoringEmailHeaderView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      DarkWebMonitoringEmailHeaderView(
        status: .active, numberOfEmailsMonitored: 1, isUnrolled: .constant(false))
      DarkWebMonitoringEmailHeaderView(
        status: .pending, numberOfEmailsMonitored: 0, isUnrolled: .constant(false))
      DarkWebMonitoringEmailHeaderView(
        status: .inactive, numberOfEmailsMonitored: 3, isUnrolled: .constant(true))
    }.previewLayout(.sizeThatFits)
      .background(Color.ds.background.default)
  }
}
