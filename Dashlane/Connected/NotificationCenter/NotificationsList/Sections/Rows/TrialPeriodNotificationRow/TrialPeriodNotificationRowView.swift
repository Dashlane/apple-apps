import SwiftUI
import NotificationKit

struct TrialPeriodNotificationRowView: View {
    @ObservedObject
    var model: TrialPeriodNotificationRowViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        BaseNotificationRowView(icon: model.notification.icon,
                                title: model.notification.title,
                                description: model.notification.description) {
            self.model.showTrialFeatureView = true
        }
                                .sheet(isPresented: $model.showTrialFeatureView) {
                                    TrialFeaturesView(viewModel: .init(capabilityService: model.capabilityService,
                                                                       deepLinkingService: model.deepLinkingService,
                                                                       activityReporter: model.activityReporter))
                                }
    }
}

struct TrialPeriodNotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TrialPeriodNotificationRowView(model: TrialPeriodNotificationRowViewModel.mock)
        }
    }
}
