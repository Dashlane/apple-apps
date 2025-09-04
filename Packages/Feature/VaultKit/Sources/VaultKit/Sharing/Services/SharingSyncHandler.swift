import CoreSync

public protocol SharingSyncHandler {
  var manualSyncHandler: () -> Void { get set }
  func sync(using sharingInfo: SharingSummaryInfo?) async throws
}
