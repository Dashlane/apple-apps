import Foundation
import BrazeKit
import Combine
import DashTypes
import CoreSettings
import CorePremium
import CoreUserTracking

public class HomeModalAnnouncementsViewModel: ObservableObject, HomeAnnouncementsServicesInjecting {

    var presentedAnnouncement: HomeModalAnnouncementType? {
        didSet {
            guard let value = presentedAnnouncement else { return }
            switch value {
            case let .bottomSheet(sheet):
                self.bottomSheet = sheet
            case let .sheet(sheet):
                self.sheet = sheet
            case let .overScreen(over):
                self.overFullScreen = over
            }
        }
    }

    @Published
    var bottomSheet: HomeBottomSheetAnnouncement?

    @Published
    var sheet: HomeSheetAnnouncement?

    @Published
    var overFullScreen: HomeOverFullScreenAnnouncement?

    var cancellables = Set<AnyCancellable>()

    public let trigger = PassthroughSubject<HomeModalAnnouncementTrigger, Never>()

    private let scheduler: HomeModalAnnouncementsScheduler

        let freeTrialFlowViewModelFactory: FreeTrialFlowViewModel.Factory
    let planRecommandationViewModelFactory: PlanRecommandationViewModel.Factory
    let rateAppViewModelFactory: RateAppViewModel.Factory
    let autofillOnboardingFlowViewModelFactory: AutofillOnboardingFlowViewModel.Factory

    public init(homeModalAnnouncementsSchedulerFactory: HomeModalAnnouncementsScheduler.Factory,
                freeTrialFlowViewModelFactory: FreeTrialFlowViewModel.Factory,
                planRecommandationViewModelFactory: PlanRecommandationViewModel.Factory,
                rateAppViewModelFactory: RateAppViewModel.Factory,
                autofillOnboardingFlowViewModelFactory: AutofillOnboardingFlowViewModel.Factory) {
        self.freeTrialFlowViewModelFactory = freeTrialFlowViewModelFactory
        self.planRecommandationViewModelFactory = planRecommandationViewModelFactory
        self.rateAppViewModelFactory = rateAppViewModelFactory
        self.autofillOnboardingFlowViewModelFactory = autofillOnboardingFlowViewModelFactory
        self.scheduler = homeModalAnnouncementsSchedulerFactory.make()
        listenTriggers()
    }

    func listenTriggers() {
                trigger
            .filter({ _ in self.sheet == nil })
            .receive(on: DispatchQueue.global(qos: .background))
            .compactMap({ trigger in
                return self.scheduler.evaluate(for: trigger)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] announcement in
                guard let self else { return }
                guard self.presentedAnnouncement == nil else {
                                        return
                }
                self.presentedAnnouncement = announcement
            })
            .store(in: &cancellables)
    }

    func dismiss(_ announcement: HomeBottomSheetAnnouncement) {
        bottomSheet = nil
    }
}

extension HomeModalAnnouncementsScheduler {
    static var mock: HomeModalAnnouncementsScheduler {
        .init(brazeInAppModalAnnouncementFactory: .init({ .mock }),
              rateAppModalAnnouncement: .init({ .mock }),
              freeTrialAnnouncement: .init({ .mock }),
              planRecommandationAnnouncement: .init({ .mock }),
              autofillActivationAnnouncement: .init({ .mock }))
    }
}

public extension HomeModalAnnouncementsViewModel {
    static var mock: HomeModalAnnouncementsViewModel {
        return .init(homeModalAnnouncementsSchedulerFactory: .init({ .mock }),
                     freeTrialFlowViewModelFactory: .init({ .mock }),
                     planRecommandationViewModelFactory: .init({ .mock }),
                     rateAppViewModelFactory: .init({ _ in .mock }),
                     autofillOnboardingFlowViewModelFactory: .init({ _ in .mock }))
    }
}
