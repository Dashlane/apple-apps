import Foundation

extension UserEvent {

  public struct `ReceiveRemoteFileUpdate`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `flowStep`: Definition.FlowStep, `packageSource`: Definition.PackageSource? = nil,
      `remoteFileUpdateError`: Definition.RemoteFileUpdateError? = nil
    ) {
      self.flowStep = flowStep
      self.packageSource = packageSource
      self.remoteFileUpdateError = remoteFileUpdateError
    }
    public let flowStep: Definition.FlowStep
    public let name = "receive_remote_file_update"
    public let packageSource: Definition.PackageSource?
    public let remoteFileUpdateError: Definition.RemoteFileUpdateError?
  }
}
