import Foundation


public struct StyxDataAPIClient {
    public static let defaultServerURL: URL = URL(string: "_")!

    let apiURL: URL
    let engine: StyxDataAPIClientEngine

    let signer: RequestSigner

    public init(apiURL: URL = Self.defaultServerURL, credentials: AppCredentials, appAPIClient: AppAPIClient) {
        self.apiURL = apiURL
        self.engine = StyxDataAPIClientEngineImpl(apiURL: apiURL,
                                                  apiClientEngine: appAPIClient.engine,
                                                  additionalHeaders: appAPIClient.configuration.additionalHeaders)
        self.signer = RequestSigner(appCredentials: credentials, userCredentials: nil)
    }
}

public extension AppAPIClient {
    func makeStyxDataClient(apiURL: URL = StyxDataAPIClient.defaultServerURL, credentials: AppCredentials) -> StyxDataAPIClient {
        StyxDataAPIClient(apiURL: apiURL, credentials: credentials, appAPIClient: self)
    }
}

extension StyxDataAPIClient {
    public enum LogCategory: String {
        case user
        case anonymous
    }


                        public func sendEvents(_ data: Data, for logCategory: LogCategory, isTestEnvironment: Bool) async throws {
        try await engine.post("event/" + logCategory.rawValue, data: data, signer: signer, isTestEnvironment: isTestEnvironment)
    }
}

