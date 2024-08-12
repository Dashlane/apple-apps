import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

protocol Attribute: PeerMacro {
  init?(from node: AttributeSyntax)

  static func validate(
    _ decl: VariableDeclSyntax, context: some SwiftSyntaxMacros.MacroExpansionContext)
}

extension Attribute {
  static var name: String { "\(Self.self)".replacingOccurrences(of: "Attribute", with: "") }

  static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    guard let variable = declaration.as(VariableDeclSyntax.self),
      !variable.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) })
    else {
      context.diagnose(
        .init(
          node: declaration._syntaxNode,
          message: MacroExpansionErrorMessage(
            "\(Self.name) can only be applied to instance variable")))
      return []
    }

    validate(variable, context: context)

    return []
  }

  static func validate(
    _ decl: VariableDeclSyntax, context: some SwiftSyntaxMacros.MacroExpansionContext
  ) {

  }

  init?(from variable: VariableDeclSyntax) {
    let attribute = variable.attributes.first { attribute in
      guard case .attribute(let attribute) = attribute else {
        return false
      }

      return attribute.attributeName.as(IdentifierTypeSyntax.self)?
        .description == Self.name
    }

    guard case .attribute(let attribute) = attribute else {
      return nil
    }

    self.init(from: attribute)
  }
}

protocol StoredAttribute: Attribute {

}

extension StoredAttribute {
  static func validate(
    _ variable: VariableDeclSyntax, context: some SwiftSyntaxMacros.MacroExpansionContext
  ) {
    if !variable.isStoredProperty {
      context.diagnose(
        .init(
          node: variable._syntaxNode,
          message: MacroExpansionErrorMessage(
            "\(Self.name) can only be applied to stored instance variable")))
    }
  }
}

struct CodingKeyAttribute: StoredAttribute {
  let value: String

  init?(from attribute: AttributeSyntax) {
    guard let argument = attribute.arguments?.as(LabeledExprListSyntax.self)?.first?.expression,
      let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
      segments.count == 1,
      case .stringSegment(let value)? = segments.first
    else {
      return nil
    }

    self.value = value.description
  }
}

struct OnSyncAttribute: StoredAttribute {
  let arguments: AttributeSyntax.Arguments

  init?(from attribute: AttributeSyntax) {
    guard let arguments = attribute.arguments else {
      return nil
    }

    self.arguments = arguments
  }
}

struct SearchableAttribute: Attribute {
  init?(from attribute: AttributeSyntax) {
  }
}
