import CorePersonalData
import DashTypes

public protocol PrefilledCredentialsProviderProtocol {
  var prefilledCredentials: [Credential] { get }
}

public class PrefilledCredentialsProvider: VaultKitServicesInjecting,
  PrefilledCredentialsProviderProtocol
{

  public let prefilledCredentials: [Credential]

  public init(
    login: Login,
    urlDecoder: PersonalDataURLDecoderProtocol
  ) {
    self.prefilledCredentials = PrefilledCredentials.all().map { credential in
      Credential(
        service: credential,
        email: login.email,
        url: try? urlDecoder.decodeURL(credential.url)
      )
    }
  }
}

extension PrefilledCredentialsProviderProtocol where Self == PrefilledCredentialsProvider {
  public static func mock(login: Login = .init("_")) -> PrefilledCredentialsProvider {
    .init(
      login: login,
      urlDecoder: .mock()
    )
  }
}
