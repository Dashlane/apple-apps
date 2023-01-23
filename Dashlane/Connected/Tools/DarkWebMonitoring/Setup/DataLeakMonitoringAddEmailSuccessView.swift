import SwiftUI
import DesignSystem
import DashlaneReportKit

struct DataLeakMonitoringAddEmailSuccessView: View {

    var dismiss: DismissAction

    let monitoredEmail: String
    let logger: DataLeakMonitoringSuccessLogger

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(asset: FiberAsset.dataLeakVerifyEmail)
            Text(L10n.Localizable.dataleakmonitoringSuccessTitle)
                .font(.title2)
                .bold()
            Text(L10n.Localizable.dataleakmonitoringSuccessDescription(monitoredEmail))
            Spacer()
            closeButton
        }
        .navigationBarHidden(true)
        .padding(.top, 40)
        .padding()
        .onAppear {
            logger.show()
        }
    }

    var closeButton: some View {
        RoundedButton(L10n.Localizable.dataleakmonitoringSuccessCloseButton) {
            logger.close()
            dismiss()
        }
        .roundedButtonLayout(.fill)
    }
}

struct DataLeakMonitoringSuccessLogger {

    private var typeSubKey: String { return "confirmation" }
    let usageLogService: UsageLogServiceProtocol

    func show() {
        let log129 = UsageLogCode129DarkwebMonitoring(type: .darkWebRegistration,
                                                      type_sub: typeSubKey,
                                                      action: .show)
        usageLogService.post(log129)
    }

    func close() {
        let log129 = UsageLogCode129DarkwebMonitoring(type: .darkWebRegistration,
                                                      type_sub: typeSubKey,
                                                      action: .close)
        usageLogService.post(log129)
    }
}

struct DataLeakMonitoringAddEmailSuccessView_Previews: PreviewProvider {

    @Environment(\.dismiss)
    static var dismiss

    static var previews: some View {
        DataLeakMonitoringAddEmailSuccessView(dismiss: dismiss,
                                              monitoredEmail: "_",
                                              logger: DataLeakMonitoringSuccessLogger(usageLogService: UsageLogService.fakeService))
    }
}
