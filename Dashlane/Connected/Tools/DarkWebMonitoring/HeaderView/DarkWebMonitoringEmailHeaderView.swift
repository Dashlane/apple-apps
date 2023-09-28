import SwiftUI
import SecurityDashboard
import Combine
import UIDelight
import DesignSystem

struct DarkWebMonitoringEmailHeaderView: View {

    let status: DarkWebMonitoringMonitoredEmailsViewModel.Status
    let numberOfEmailsMonitored: Int

    @Binding
    var isUnrolled: Bool

    init(status: DarkWebMonitoringMonitoredEmailsViewModel.Status, numberOfEmailsMonitored: Int, isUnrolled: Binding<Bool>) {
        self.status = status
        self.numberOfEmailsMonitored = numberOfEmailsMonitored
        self._isUnrolled = isUnrolled
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isUnrolled.toggle()
            }
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(emailMonitoredLabel).font(.body)
                    statusBadge
                }
                Spacer()
                chevronIndicator
            }
            .accessibilityElement(children: .combine)
            .fiberAccessibilityLabel(Text(
                "\(emailMonitoredLabel) \(statusText) \(isUnrolled ? L10n.Localizable.accessibilityCollapse : L10n.Localizable.accessibilityExpand)"
            ))
            .padding(16)
            .frame(height: 75)
        })
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier("ExpandMonitoredEmailsButton")
    }

    @ViewBuilder
    private var statusBadge: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(indicatorColor)
            Text(statusText)
                .font(.callout)
                .foregroundColor(.ds.text.neutral.quiet)
        }
    }

    var emailMonitoredLabel: String {
        switch status {
        case .active, .pending:
            if numberOfEmailsMonitored == 1 {
                return L10n.Localizable.darkWebMonitoringEmailHeaderViewOneEmailMonitored(numberOfEmailsMonitored)
            } else {
                return L10n.Localizable.darkWebMonitoringEmailHeaderViewMultiEmailMonitored(numberOfEmailsMonitored)
            }
        case .inactive:
            if numberOfEmailsMonitored == 1 {
                return L10n.Localizable.darkWebMonitoringEmailHeaderViewOneEmailInactive(numberOfEmailsMonitored)
            } else {
                return L10n.Localizable.darkWebMonitoringEmailHeaderViewMultiEmailInactive(numberOfEmailsMonitored)
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
            .foregroundColor(.ds.text.inverse.quiet)
            .rotationEffect(Angle.degrees(isUnrolled ? 180 : 0))
            .animation(.easeOut, value: isUnrolled)
    }
}

struct DarkWebMonitoringEmailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            DarkWebMonitoringEmailHeaderView(status: .active, numberOfEmailsMonitored: 1, isUnrolled: .constant(false))
                .background(Color(asset: FiberAsset.dwmMainBackground))
            DarkWebMonitoringEmailHeaderView(status: .pending, numberOfEmailsMonitored: 0, isUnrolled: .constant(false))
                .background(Color(asset: FiberAsset.dwmMainBackground))
            DarkWebMonitoringEmailHeaderView(status: .inactive, numberOfEmailsMonitored: 3, isUnrolled: .constant(true))
                .background(Color(asset: FiberAsset.dwmMainBackground))
        }.previewLayout(.sizeThatFits)
    }
}
