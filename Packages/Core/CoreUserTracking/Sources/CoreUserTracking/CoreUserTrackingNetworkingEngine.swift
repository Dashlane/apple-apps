import Foundation

public protocol CoreUserTrackingNetworkingEngine {

    func sendRequest(to url: URL,
                     input: Data,
                     timeout: TimeInterval?,
                     additionalHTTPHeaders: [String: String]) async throws
}
