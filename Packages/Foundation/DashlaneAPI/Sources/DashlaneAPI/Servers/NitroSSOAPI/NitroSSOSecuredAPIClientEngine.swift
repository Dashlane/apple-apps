import Foundation

struct NitroSSOSecuredAPIClientEngine: APIClientEngine {
  struct EncryptedInput: Encodable {
    let data: String
  }

  let baseEngine: APIClientEngine
  let secureTunnel: SecureTunnel

  func post<Response: Decodable & Sendable, Body: Encodable & Sendable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response {
    let encryptedPayload = try secureTunnel.push(body)
    let body = EncryptedInput(data: encryptedPayload.hexadecimalString())

    let result: String = try await baseEngine.post(
      endpoint,
      body: body,
      timeout: timeout,
      signer: signer)
    let decrypted = try secureTunnel.pull(Response.self, from: result.hexaData())
    return decrypted
  }

  func get<Response: Decodable & Sendable>(
    _ endpoint: Endpoint,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response {
    let result: String = try await baseEngine.get(endpoint, timeout: timeout, signer: signer)
    let decrypted = try secureTunnel.pull(Response.self, from: result.hexaData())
    return decrypted
  }
}

extension Data {
  func hexadecimalString() -> String {
    return map {
      String.init(format: "%02hhx", $0)
    }.joined()
  }
}

extension StringProtocol {
  func hexaData() -> Data { .init(hexa()) }

  private func hexa() -> UnfoldSequence<UInt8, Index> {
    sequence(state: startIndex) { startIndex in
      guard startIndex < self.endIndex else { return nil }
      let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
      defer { startIndex = endIndex }
      return UInt8(self[startIndex..<endIndex], radix: 16)
    }
  }
}
