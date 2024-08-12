import Foundation

struct NamespaceMetadata: Encodable {
  struct Properties: Encodable {
    let providesNamespace: Bool = true

    enum CodingKeys: String, CodingKey {
      case providesNamespace = "provides-namespace"
    }
  }

  let info: Info = Info()
  let properties: Properties = Properties()
}
