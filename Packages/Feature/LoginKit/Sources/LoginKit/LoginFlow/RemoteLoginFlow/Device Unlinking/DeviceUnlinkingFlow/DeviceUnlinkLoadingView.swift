import Combine
import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import SwiftUILottie
import UIComponents

struct DeviceUnlinkLoadingView: View {
  var viewModel: DeviceUnlinkLoadingViewModel

  @State
  private var animationState: LottieView.State = .marker(toMarker: "End Load Start Checkmark")

  private var title: String {
    switch animationState {
    case .finish:
      return CoreL10n.accountLoadingSuccessTitle
    default:
      return viewModel.mode.title
    }
  }

  private var description: String {
    switch animationState {
    case .finish:
      return CoreL10n.accountLoadingSuccessDescription
    default:
      return CoreL10n.accountLoadingMayTakeMinute
    }
  }

  var body: some View {
    VStack {
      LottieView(.loading, state: animationState)
        .frame(width: 72, height: 72)
      Spacer()
        .frame(height: 120)
      Text(title)
        .textStyle(.specialty.spotlight.small)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Spacer()
        .frame(height: 30)
      Text(description)
        .foregroundStyle(Color.ds.text.neutral.catchy)
    }
    .navigationBarBackButtonHidden(true)
    .onReceive(viewModel.actionPublisher) { action in
      switch action {
      case let .finish(onComplete):
        self.animationState = .finish(animationSpeed: 0.7, onComplete: onComplete)
      }
    }
  }
}

struct DeviceUnlinkLoadingView_Preview: PreviewProvider {
  static var previews: some View {
    DeviceUnlinkLoadingView(viewModel: .mock)
  }
}

extension DeviceUnlinkMode {
  fileprivate var title: String {
    switch self {
    case .purchasedPremium:
      return CoreL10n.accountLoadingInfoText
    case let .unlinkedDevices(devices):
      switch devices.count {
      case 0:
        return CoreL10n.accountLoadingUnlinkingPrevious
      case 1:
        return CoreL10n.deviceUnlinkLoadingUnlinkDevice
      default:
        return CoreL10n.deviceUnlinkLoadingUnlinkDevices
      }
    }
  }
}
