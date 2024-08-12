import Foundation
import SwiftSyntax

extension VariableDeclSyntax {
  func name() -> String? {
    return bindings.first {
      $0.pattern.is(IdentifierPatternSyntax.self)
    }?.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed.text
  }

  func hasAttribute(_ attribute: String) -> Bool {
    return attributes.contains {
      $0.as(AttributeSyntax.self)?
        .attributeName
        .as(IdentifierTypeSyntax.self)?
        .name.tokenKind == .identifier(attribute)
    }
  }

  var isStoredProperty: Bool {
    guard
      !modifiers.compactMap({ $0.as(DeclModifierSyntax.self) }).contains(where: {
        $0.name.text == "static"
      }),
      bindings.count > 0
    else {
      return false
    }

    let binding = bindings.last!
    switch binding.accessorBlock?.accessors {
    case .none:
      return true
    case let .accessors(accessors):
      return accessors.allSatisfy { accessor in
        switch accessor.accessorSpecifier.tokenKind {
        case .keyword(.willSet), .keyword(.didSet):
          return true
        default:
          return false
        }
      }

    case .getter:
      return false
    }
  }
}
