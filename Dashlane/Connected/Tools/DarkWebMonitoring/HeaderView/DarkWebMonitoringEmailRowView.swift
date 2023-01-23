import SwiftUI
import CorePersonalData
import SecurityDashboard
import Combine
import UIDelight
import VaultKit

struct DarkWebMonitoringEmailRowView: View {

    @ObservedObject
    var model: DarkWebMonitoringEmailRowViewModel

    var body: some View {
        HStack {
            GravatarIconView(model: model.makeGravatarIconViewModel(), isLarge: false)
            VStack(alignment: .leading, spacing: 3) {
                Text(model.title).font(.body)
                Text(title(for: model.status))
                    .font(.footnote)
                    .foregroundColor(titleColor(for: model.status))
            }.padding(.leading, 16)
            Spacer()
            Button(action: { model.actionPublisher.send(.deleteEmail(model.title)) }, label: {
                Image(systemName: "xmark").foregroundColor(Color(asset: FiberAsset.neutralText))
            })
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
            return Color(asset: FiberAsset.grey01)
        case .pending:
            return Color(asset: FiberAsset.dashlaneOrange)
        case .disabled:
            return Color(asset: FiberAsset.grey01)
        }
    }
}

struct DarkWebMonitoringEmailRowView_Previews: PreviewProvider {

    private static var model
        = DarkWebMonitoringEmailRowViewModel(email: DataLeakEmail("_"),
                                             iconService: IconServiceMock(),
                                             actionPublisher: .init())

    private static var notMonitoredModel
    = DarkWebMonitoringEmailRowViewModel(email: DataLeakEmail("_"),
                                         iconService: IconServiceMock(),
                                         actionPublisher: .init())

    static var previews: some View {
        MultiContextPreview {
            VStack {
                DarkWebMonitoringEmailRowView(model: model)
                DarkWebMonitoringEmailRowView(model: notMonitoredModel)
            }.background(Color(asset: FiberAsset.dashGreenCopy))
        }
        .previewLayout(.sizeThatFits)
    }
}
