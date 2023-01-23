import SwiftUI
import CorePersonalData
import Combine
import SecurityDashboard
import UIDelight
import UIComponents
import DesignSystem

struct DarkWebMonitoringMonitoredEmailsView<Model: DarkWebMonitoringMonitoredEmailsViewModelProtocol>: View {

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

            DarkWebMonitoringEmailHeaderView(status: model.status,
                                             numberOfEmailsMonitored: model.numberOfEmailsMonitored,
                                             isUnrolled: $model.shouldShowEmailSection)

        }
        .background(.ds.container.expressive.brand.quiet.idle)
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
                addEmailButton.hidden(!model.isMonitoringEnabled)
                numberOfSpotsAvailableText.hidden(!model.isMonitoringEnabled)
            }
        }
        .onTapGesture {
                    }
        .frame(idealHeight: 440, maxHeight: 440)
    }

    @ViewBuilder
    private var addEmailButton: some View {
        RoundedButton(L10n.Localizable.darkWebMonitoringEmailListViewAddEmail, action: model.addEmail)
            .roundedButtonLayout(.fill)
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
        }.frame(maxWidth: .infinity)
    }
}

struct DarkWebMonitoringHeaderView_Previews: PreviewProvider {

    static var previews: some View {
        MultiContextPreview {
            DarkWebMonitoringMonitoredEmailsView(model: FakeDarkWebMonitoringMonitoredEmailsViewModel(shouldShowEmailSection: true))
                .background(Color(asset: FiberAsset.dwmMainBackground))

            DarkWebMonitoringMonitoredEmailsView(model: FakeDarkWebMonitoringMonitoredEmailsViewModel(shouldShowEmailSection: false))
                .background(Color(asset: FiberAsset.dwmMainBackground))
        }
    }
}
