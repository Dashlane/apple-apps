import Foundation

extension Definition {

  public enum `PublicApiKeyStep`: String, Encodable, Sendable {
    case `copyKey` = "copy_key"
    case `createKey` = "create_key"
    case `downloadKey` = "download_key"
    case `generateKey` = "generate_key"
    case `keyGenerated` = "key_generated"
    case `keyGenerationFailed` = "key_generation_failed"
  }
}
