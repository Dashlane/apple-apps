import Combine
import CoreSession
import CoreTypes
import Foundation
import LogFoundation
import SwiftUI
import UserTrackingFoundation

enum DeviceUnlinkMode {
  case purchasedPremium
  case unlinkedDevices(_ devices: Set<DeviceListEntry>)
}

@MainActor
public class DeviceUnlinkingFlowViewModel: ObservableObject, LoginKitServicesInjecting {
  enum Alert {
    case unlinkFailed(Set<DeviceListEntry>, error: Error)
    case purchaseFailed(Error)
  }

  enum Step {
    case initial(
      mode: DeviceUnlinker.UnlinkMode,
      action: (LimitedNumberOfDeviceView.Action) -> Void)
    case monobucketUnlink(
      device: BucketDevice,
      action: (MonobucketUnlinkView.Action) -> Void)
    case multiDevice(
      limit: Int,
      devices: [DeviceListEntry],
      action: (UnlinkMutltiDevicesView.Action) -> Void)
    case purchasePlanFlow(flow: AnyView)
    case loading(DeviceUnlinkMode)
  }

  public enum Completion {
    case logout
    case load(actionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>)
  }

  @Published
  var steps: [Step] = []

  @Published
  var alert: Alert?

  let deviceUnlinker: DeviceUnlinker
  let login: Login
  let authentication: ServerAuthentication
  let userTrackingSessionActivityReporter: ActivityReporterProtocol
  let logger: Logger
  let completion: (Completion) -> Void
  let purchasePlanFlowProvider: PurchasePlanFlowProvider
  let actionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never> = .init()

  public convenience init(
    deviceUnlinker: DeviceUnlinker,
    login: Login,
    session: RemoteLoginSession,
    logger: Logger,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    completion: @escaping @MainActor (DeviceUnlinkingFlowViewModel.Completion) -> Void
  ) {
    let userTrackingSessionActivityReporter =
      sessionActivityReporterProvider.makeSessionActivityReporter(
        for: login,
        analyticsId: session.analyticsIds)
    self.init(
      deviceUnlinker: deviceUnlinker,
      login: login,
      authentication: session.authentication,
      logger: logger,
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      userTrackingSessionActivityReporter: userTrackingSessionActivityReporter,
      completion: completion)
  }

  public init(
    deviceUnlinker: DeviceUnlinker,
    login: Login,
    authentication: ServerAuthentication,
    logger: Logger,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    userTrackingSessionActivityReporter: ActivityReporterProtocol,
    completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void
  ) {
    self.login = login
    self.logger = logger
    self.authentication = authentication
    self.userTrackingSessionActivityReporter = userTrackingSessionActivityReporter
    self.completion = completion
    self.deviceUnlinker = deviceUnlinker
    self.purchasePlanFlowProvider = purchasePlanFlowProvider
    initialStep()
  }

  func initialStep() {
    guard let mode = deviceUnlinker.mode else {
      self.completion(.load(actionPublisher: actionPublisher))
      return
    }

    showLimitedNumberOfDevicesView(mode: mode)
    userTrackingSessionActivityReporter.reportPageShown(.paywallDeviceSyncLimit)
  }

  func unlinkAndLoadSession(mode: DeviceUnlinkMode, using deviceUnlinker: DeviceUnlinker) {
    self.steps.append(.loading(mode))

    guard case let .unlinkedDevices(devices) = mode else {
      self.completion(.load(actionPublisher: actionPublisher))
      return
    }

    Task {
      do {
        try await deviceUnlinker.unlink(devices)
        self.completion(.load(actionPublisher: self.actionPublisher))
      } catch {
        self.logger.error("Unlink failed", error: error)
        self.alert = .unlinkFailed(devices, error: error)
      }
    }
  }

  func showPurchasePlanFlow() {
    Task {
      do {
        let flow = try await purchasePlanFlowProvider.makePurchasePlanFlow(
          for: login,
          authentication: authentication
        ) { completion in
          guard completion == .successful else {
            return
          }
          self.unlinkAndLoadSession(mode: .purchasedPremium, using: self.deviceUnlinker)
        }
        self.steps.append(.purchasePlanFlow(flow: flow))
      } catch {
        alert = Alert.purchaseFailed(error)
      }

    }
  }

  func retryAction(devices: Set<DeviceListEntry>) {
    self.unlinkAndLoadSession(mode: .unlinkedDevices(devices), using: deviceUnlinker)
  }
}
