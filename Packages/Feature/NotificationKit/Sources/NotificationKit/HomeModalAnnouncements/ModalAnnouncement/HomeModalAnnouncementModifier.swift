import BrazeKit
import SwiftTreats
import SwiftUI
import UIComponents

struct HomeModalAnnouncementModifier: ViewModifier {

  @ObservedObject
  var model: HomeModalAnnouncementsViewModel

  @Environment(\.sizeCategory) var sizeCategory

  @State
  private var showAlert: Bool = false

  func body(content: Content) -> some View {
    ZStack {
      nativeBottomSheetView(content: content)
    }
    .overFullScreen(item: $model.overFullScreen) { announcement in
      switch announcement {
      case .rateApp:
        RateAppView(viewModel: model.rateAppViewModelFactory.make(sender: .braze))
      }
    }
    .sheet(item: $model.sheet) { announcement in
      switch announcement {
      case .freeTrial(let daysLeft):
        FreeTrialFlowView(viewModel: model.freeTrialFlowViewModelFactory.make(daysLeft: daysLeft))
      case .planRecommandation:
        PlanRecommandationView(viewModel: model.planRecommandationViewModelFactory.make())
      case .autofillActivation:
        AutofillOnboardingFlowView(
          model: model.autofillOnboardingFlowViewModelFactory.make(completion: { model.sheet = nil }
          ))
      }
    }
    .modifier(AlertAnnouncementModifier(announcement: model.alert, isPresented: $showAlert))
    .onChange(of: model.alert) { newValue in
      self.showAlert = newValue != nil
    }
  }

  func nativeBottomSheetView(content: Content) -> some View {
    content
      .sheet(
        item: $model.bottomSheet,
        content: { announcement in
          switch announcement {
          case let .braze(brazeAnnouncement):
            BrazeAnnouncementContainerView(
              announcement: brazeAnnouncement, dismiss: { model.dismiss(announcement) })
          }
        })
  }
}

struct AlertAnnouncementModifier: ViewModifier {

  let announcement: HomeAlertAnnouncement?
  @Binding
  var isPresented: Bool

  func body(content: Content) -> some View {
    switch announcement {
    case .upgradeOperatingSystem:
      content.modifier(UpdateOperatingSystemAlertModifier(isPresented: $isPresented))
    default:
      content
    }
  }

}

extension View {
  public func homeModalAnnouncements(model: HomeModalAnnouncementsViewModel) -> some View {
    self.modifier(HomeModalAnnouncementModifier(model: model))
  }
}
