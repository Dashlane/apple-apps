import Foundation

protocol APIClient {
    var signer: RequestSigner { get }
    var engine: APIClientEngine { get }
}

extension APIClient {
    func post<Response: Decodable, Body: Encodable>(_ endpoint: Endpoint,
                                                    body: Body,
                                                    timeout: TimeInterval? = nil) async throws -> Response {
        return try await engine.post(endpoint, body: body, timeout: timeout, signer: signer)
    }

    func get<Response: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval? = nil) async throws -> Response {
        return try await engine.get(endpoint, timeout: timeout, signer: signer)
    }
}

public typealias Endpoint = String
public struct Empty: Codable, Equatable {}

public struct AppAPIClient: APIClient {
    let engine: APIClientEngine
    let signer: RequestSigner
    let configuration: APIConfiguration
    let appCredentials: AppCredentials

    public init(configuration: APIConfiguration, appCredentials: AppCredentials) {
        self.appCredentials = appCredentials
        self.configuration = configuration
        self.signer = RequestSigner(appCredentials: appCredentials,
                                    userCredentials: nil)
        self.engine = APIClientEngineImpl(configuration: configuration)
    }

    init(engine: APIClientEngine, signer: RequestSigner, configuration: APIConfiguration, appCredentials: AppCredentials) {
        self.engine = engine
        self.signer = signer
        self.configuration = configuration
        self.appCredentials = appCredentials
    }
}

public struct UserDeviceAPIClient: APIClient {
    let configuration: APIConfiguration
    let appCredentials: AppCredentials
    let userCredentials: UserCredentials
    let signer: RequestSigner
    let engine: APIClientEngine

    init(configuration: APIConfiguration,
         appCredentials: AppCredentials,
         userCredentials: UserCredentials,
         engine: APIClientEngine) {
        self.configuration = configuration
        self.appCredentials = appCredentials
        self.userCredentials = userCredentials
        self.engine = engine
        self.signer = RequestSigner(appCredentials: appCredentials,
                                    userCredentials: userCredentials)
    }
}

extension AppAPIClient {
    public func makeUserClient(credentials: UserCredentials) -> UserDeviceAPIClient {
       return UserDeviceAPIClient(configuration: configuration, appCredentials: appCredentials, userCredentials: credentials, engine: engine)
    }
}

public typealias DateDay = Date
public typealias ID = UUID
public typealias File = Data
public typealias DateTime = Data

func test(_ api: UserDeviceAPIClient) async {

    do {
        let response = try await api.sync.getLatestContent(timestamp: 1, transactions: [], needsKeys: true, teamAdminGroups: false)
        print(response)
    } catch let error as APIError where error.hasSyncCode(.deviceNotFound) {

    } catch {

    }
}
