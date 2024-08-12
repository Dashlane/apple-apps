#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIComponents
  import DesignSystem
  import Combine
  import CoreLocalization

  struct DeviceUnlinkLoadingView: View {
    var viewModel: DeviceUnlinkLoadingViewModel

    @State
    private var animationState: LottieView.State = .marker(toMarker: "End Load Start Checkmark")

    private var title: String {
      switch animationState {
      case .finish:
        return L10n.Core.accountLoadingSuccessTitle
      default:
        return viewModel.mode.title
      }
    }

    private var description: String {
      switch animationState {
      case .finish:
        return L10n.Core.accountLoadingSuccessDescription
      default:
        return L10n.Core.accountLoadingMayTakeMinute
      }
    }

    var body: some View {
      VStack {
        LottieView(.loading, state: animationState)
          .frame(width: 72, height: 72)
        Spacer()
          .frame(height: 120)
        Text(title)
          .font(DashlaneFont.custom(28, .regular).font)
          .foregroundColor(.ds.text.neutral.catchy)
        Spacer()
          .frame(height: 30)
        Text(description)
          .foregroundColor(.ds.text.neutral.catchy)
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
        return L10n.Core.accountLoadingInfoText
      case let .unlinkedDevices(devices):
        switch devices.count {
        case 0:
          return L10n.Core.accountLoadingUnlinkingPrevious
        case 1:
          return L10n.Core.deviceUnlinkLoadingUnlinkDevice
        default:
          return L10n.Core.deviceUnlinkLoadingUnlinkDevices
        }
      }
    }
  }
#endif
