import SwiftUI
import BrazeKit
import UIComponents
import SwiftTreats

struct HomeModalAnnouncementModifier: ViewModifier {

    @ObservedObject
    var model: HomeModalAnnouncementsViewModel

    @Environment(\.sizeCategory) var sizeCategory

    func body(content: Content) -> some View {
        ZStack {
            if bottomSheetShouldBeNative {
                nativeBottomSheetView(content: content)
            } else {
                legacyBottomSheet(content: content)
            }
        }
        .overFullScreen(item: $model.overFullScreen) { announcement in
            switch announcement {
            case .rateApp:
                RateAppView(viewModel: model.rateAppViewModelFactory.make(sender: .braze))
            }
        }
        .sheet(item: $model.sheet) { announcement in
            switch announcement {
            case .freeTrial:
                FreeTrialFlowView(viewModel: model.freeTrialFlowViewModelFactory.make())
            case .planRecommandation:
                PlanRecommandationView(viewModel: model.planRecommandationViewModelFactory.make())
            case .autofillActivation:
                AutofillOnboardingFlowView(model: model.autofillOnboardingFlowViewModelFactory.make(completion: {}))
            }
        }
    }

    func legacyBottomSheet(content: Content) -> some View {
        content
            .bottomSheet(item: $model.bottomSheet, content: { announcement in
                switch announcement {
                case let .braze(brazeAnnouncement):
                    BrazeAnnouncementContainerView(announcement: brazeAnnouncement, dismiss: { model.dismiss(announcement) })
                        .hideTabBar()
                }
            })
    }

    func nativeBottomSheetView(content: Content) -> some View {
        content
            .sheet(item: $model.bottomSheet, content: { announcement in
                switch announcement {
                case let .braze(brazeAnnouncement):
                    BrazeAnnouncementContainerView(announcement: brazeAnnouncement, dismiss: { model.dismiss(announcement) })
                }
            })
    }


    private var bottomSheetShouldBeNative: Bool {
        if Device.isIpadOrMac {
                        return true
        } else if #available(iOS 16, *) {
                        return true
        } else {
                        return false
        }
    }
}

public extension View {
    func homeModalAnnouncements(model: HomeModalAnnouncementsViewModel) -> some View {
        self.modifier(HomeModalAnnouncementModifier(model: model))
    }
}
