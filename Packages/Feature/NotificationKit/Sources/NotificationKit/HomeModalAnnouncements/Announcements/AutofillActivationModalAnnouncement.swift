import Foundation
import CoreSettings
import DashTypes
import CoreFeature
import Combine

public class AutofillActivationModalAnnouncement: HomeModalAnnouncement, HomeAnnouncementsServicesInjecting {

    private let userSettings: UserSettings
    let identifier: String = UUID().uuidString

    let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]
    private let abTestingService: ABTestingServiceProtocol

    private var activationStatus: AutofillActivationStatus = .unknown
    private var subscriptions: Set<AnyCancellable> = []

    var announcement: HomeModalAnnouncementType? {
        guard shouldDisplay() else { return nil }
        return .sheet(.autofillActivation)
    }

    public init(userSettings: UserSettings,
                autofillService: NotificationKitAutofillServiceProtocol,
                abTestingService: ABTestingServiceProtocol) {
        self.userSettings = userSettings
        self.abTestingService = abTestingService

        autofillService.notificationKitActivationStatus.sink { status in
            self.activationStatus = status
        }
        .store(in: &subscriptions)
    }

    func shouldDisplay() -> Bool {
                if let autofillActivationPopUpHasBeenShown: Bool = userSettings[.autofillActivationPopUpHasBeenShown] {
            guard autofillActivationPopUpHasBeenShown == false else {
                return false
            }
        }

                guard activationStatus == .disabled else {
            return false
        }

                guard abTestingService.get(test: ABTest.AutofillIosActivationbannereducation.self)?.variant == .a else {
            return false
        }

        return true

        
    }
}

extension AutofillActivationModalAnnouncement {
    static var mock: AutofillActivationModalAnnouncement {
        .init(userSettings: .mock, autofillService: FakeNotificationKitAutofillService(), abTestingService: ABTestingServiceMock.mock)
    }
}
