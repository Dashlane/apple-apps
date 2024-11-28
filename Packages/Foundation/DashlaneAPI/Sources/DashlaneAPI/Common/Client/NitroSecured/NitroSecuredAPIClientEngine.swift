import Foundation

struct NitroSecuredAPIClientEngine: APIClientEngine {
  let baseEngine: APIClientEngine
  let secureTunnel: SecureTunnel

  func post<Response: Decodable, Body: Encodable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response {
    let encryptedPayload = try secureTunnel.push(body)
    let result: String = try await baseEngine.post(
      endpoint,
      body: EncryptedInput(data: encryptedPayload.hexadecimalString()),
      timeout: timeout,
      signer: signer)
    let decrypted = try secureTunnel.pull(Response.self, from: result.hexaData())
    return decrypted
  }

  func get<Response: Decodable>(
    _ endpoint: Endpoint,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response {
    let result: String = try await baseEngine.get(endpoint, timeout: timeout, signer: signer)
    let decrypted = try secureTunnel.pull(Response.self, from: result.hexaData())
    return decrypted
  }
}

extension APIClientEngine {
  func secured(with secureTunnel: SecureTunnel) -> APIClientEngine {
    return NitroSecuredAPIClientEngine(baseEngine: self, secureTunnel: secureTunnel)
  }
}

struct EncryptedInput: Encodable {
  let data: String
}

extension Data {
  fileprivate func hexadecimalString() -> String {
    return map {
      String.init(format: "%02hhx", $0)
    }.joined()
  }
}

extension StringProtocol {
  fileprivate func hexaData() -> Data { .init(hexa()) }

  private func hexa() -> UnfoldSequence<UInt8, Index> {
    sequence(state: startIndex) { startIndex in
      guard startIndex < self.endIndex else { return nil }
      let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
      defer { startIndex = endIndex }
      return UInt8(self[startIndex..<endIndex], radix: 16)
    }
  }
}
