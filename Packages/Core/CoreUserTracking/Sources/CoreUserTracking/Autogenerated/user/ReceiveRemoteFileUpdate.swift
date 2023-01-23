import Foundation

extension UserEvent {

public struct `ReceiveRemoteFileUpdate`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`flowStep`: Definition.FlowStep, `remoteFileUpdateError`: Definition.RemoteFileUpdateError? = nil) {
self.flowStep = flowStep
self.remoteFileUpdateError = remoteFileUpdateError
}
public let flowStep: Definition.FlowStep
public let name = "receive_remote_file_update"
public let remoteFileUpdateError: Definition.RemoteFileUpdateError?
}
}
