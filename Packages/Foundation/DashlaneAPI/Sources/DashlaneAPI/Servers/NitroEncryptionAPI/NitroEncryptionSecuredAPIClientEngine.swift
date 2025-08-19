import Foundation

actor NitroEncryptionSecuredAPIClientEngine: APIClientEngine {
  struct TunnelSession: Sendable {
    let tunnelUUID: String
    let secureTunnel: SecureTunnel
  }

  let secureTunnelCreatorType: any NitroSecureTunnelCreator.Type
  let appClient: AppNitroEncryptionAPIClient
  private var currentTunnelSession: TunnelSession?
  private let serializedTasksStream = AsyncStream<@Sendable () async -> Void>.makeStream()
  private let serializedTask: Task<Void, Never>

  init(
    secureTunnelCreatorType: any NitroSecureTunnelCreator.Type,
    appClient: AppNitroEncryptionAPIClient
  ) {
    self.secureTunnelCreatorType = secureTunnelCreatorType
    self.appClient = appClient

    serializedTask = Task { [serializedTasksStream] in
      for await task in serializedTasksStream.stream {
        await task()
      }
    }
  }

  deinit {
    serializedTask.cancel()
  }

  func post<Response: Decodable & Sendable, Body: Encodable & Sendable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response {
    try await withTunnelSession { [appClient] session in

      let encryptedPayload = try session.secureTunnel.push(body)

      let body = SecureTunnelEncryptedInput(
        tunnelUuid: session.tunnelUUID,
        encryptedData: encryptedPayload.hexadecimalString())

      let result: SecureTunnelEncryptedOutput = try await appClient.engine.post(
        endpoint,
        body: body,
        timeout: timeout,
        signer: signer)
      return try session.secureTunnel.pull(Response.self, from: result.encryptedData.hexaData())
    }

  }

  func get<Response: Decodable & Sendable>(
    _ endpoint: Endpoint,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response {
    try await withTunnelSession { [appClient] session in
      let result: SecureTunnelEncryptedOutput = try await appClient.engine.get(
        endpoint, timeout: timeout, signer: signer)
      return try session.secureTunnel.pull(Response.self, from: result.encryptedData.hexaData())
    }
  }

}

extension NitroEncryptionSecuredAPIClientEngine {
  static let retryCountMax = 1

  private func tunnelSession() async throws -> TunnelSession {
    if let currentTunnelSession {
      return currentTunnelSession
    }

    let secureTunnelCreator = try secureTunnelCreatorType.init()
    let response = try await appClient.tunnel.clientHello(
      clientPublicKey: secureTunnelCreator.publicKey)
    let secureTunnel = try secureTunnelCreator.create(withRawAttestation: response.attestation)
    try await appClient.tunnel.terminateHello(
      clientHeader: secureTunnel.header, tunnelUuid: response.tunnelUuid)
    let session = TunnelSession(tunnelUUID: response.tunnelUuid, secureTunnel: secureTunnel)
    currentTunnelSession = session
    return session
  }

  private func withTunnelSession<T: Sendable>(
    _ action: @escaping @Sendable (TunnelSession) async throws -> T
  ) async throws -> T {
    return try await withCheckedThrowingContinuation {
      [serializedTasksStream] currentContinuation in
      serializedTasksStream.continuation.yield { @Sendable in
        var shouldRetry: Bool = false
        var retryCount: Int = 0

        repeat {
          do {
            shouldRetry = false
            let session = try await self.tunnelSession()
            let response = try await action(session)
            currentContinuation.resume(returning: response)
          }

          catch let error as NitroEncryptionError
            where error.shouldRecreateTunnel && retryCount < Self.retryCountMax
          {
            await self.clearSession()
            retryCount += 1
            shouldRetry = true
          } catch {
            currentContinuation.resume(throwing: error)
            shouldRetry = false
          }
        } while shouldRetry
      }
    }
  }

  func clearSession() {
    self.currentTunnelSession = nil
  }
}

struct _MockedSecureTunnelRequest<Request: APIRequest>: APIRequest {
  public typealias Response = SecureTunnelEncryptedOutput
  public typealias Body = SecureTunnelEncryptedInput

  public static var endpoint: String { Request.endpoint }
}

extension MockedRequestImpl {
  func tunnelSecured() -> MockedRequestImpl<_MockedSecureTunnelRequest<Request>>
  where Request.Body: Decodable {
    let tunnel = SecureTunnelMock()
    return MockedRequestImpl<_MockedSecureTunnelRequest<Request>>(endpoint: endpoint) {
      (data: SecureTunnelEncryptedInput, invocation: Int) -> SecureTunnelEncryptedOutput in

      let body: Request.Body = try tunnel.pull(
        Request.Body.self, from: data.encryptedData.hexaData())
      let repsonse: Request.Response = try await response(body, invocation)
      let responseData = try tunnel.push(repsonse)

      return .init(encryptedData: responseData.hexadecimalString())
    }
  }
}

extension NitroEncryptionError {
  var shouldRecreateTunnel: Bool {
    NitroEncryptionErrorCodes.Tunnel.recreateTunnelErrorCodes.contains(where: hasTunnelCode)
  }
}

extension NitroEncryptionErrorCodes.Tunnel {
  static let recreateTunnelErrorCodes: [NitroEncryptionErrorCodes.Tunnel] = [
    .clientIdentifierNotFound,
    .clientSessionKeysNotFound,
    .clientStateinNotFound,
    .tunnelUUIDNotFound,

    .secureTunnelMustBeReopened,
  ]
}
