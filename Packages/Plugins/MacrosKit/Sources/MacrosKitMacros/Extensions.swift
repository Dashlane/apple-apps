import Foundation
import SwiftSyntax

extension DeclGroupSyntax {
  public var properties: [VariableDeclSyntax] {
    return memberBlock.members.compactMap({ $0.decl.as(VariableDeclSyntax.self) })
  }

  public var storedProperties: [VariableDeclSyntax] {
    return properties.filter(\.isStored)
  }

  public var initializers: [InitializerDeclSyntax] {
    return memberBlock.members.compactMap({ $0.decl.as(InitializerDeclSyntax.self) })
  }
  public var associatedTypes: [AssociatedTypeDeclSyntax] {
    return memberBlock.members.compactMap({ $0.decl.as(AssociatedTypeDeclSyntax.self) })
  }
}

extension VariableDeclSyntax {
  public var isComputed: Bool {
    return bindings.contains(where: { $0.accessorBlock != nil })
  }

  public var isStored: Bool {
    return !isComputed
  }

  public var isFixed: Bool {
    return initializerValue != nil && self.bindingSpecifier.tokenKind == .keyword(.let)
  }

  public var isStatic: Bool {
    return modifiers.lazy.contains(where: { $0.name.tokenKind == .keyword(.static) }) == true
  }

  public var identifier: TokenSyntax {
    return bindings.lazy.compactMap({ $0.pattern.as(IdentifierPatternSyntax.self) }).first!
      .identifier
  }

  public var type: TypeAnnotationSyntax? {
    return bindings.lazy.compactMap(\.typeAnnotation).first
  }

  public var initializerValue: ExprSyntax? {
    return bindings.lazy.compactMap(\.initializer).first?.value
  }
}

extension VariableDeclSyntax {
  func hasAttributes(_ attribute: String) -> Bool {
    return attributes.contains {
      $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.tokenKind
        == .identifier(attribute)
    }
  }

  func firstAttributeName() -> String? {
    return attributes.lazy.compactMap {
      guard
        case let .identifier(attribute) = $0.as(AttributeSyntax.self)?.attributeName.as(
          IdentifierTypeSyntax.self)?.name.tokenKind
      else {
        return nil
      }

      return attribute
    }.first
  }
}

extension TypeSyntax {
  var isOptional: Bool {
    if self.is(OptionalTypeSyntax.self) {
      return true
    } else if let type = self.as(IdentifierTypeSyntax.self),
      type.name.text == "Optional",
      let gArgs = type.genericArgumentClause?.arguments,
      gArgs.count == 1
    {
      return true
    } else {
      return false
    }
  }
}
