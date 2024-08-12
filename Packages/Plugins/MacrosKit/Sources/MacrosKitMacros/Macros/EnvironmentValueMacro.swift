import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EnvironmentValueMacro {
  enum Message: String, DiagnosticMessage {
    case noDefaultArgument
    case applyOnlyToVar
    case missingAnnotation
    case notAnIdentifier

    var severity: DiagnosticSeverity { return .error }

    var message: String {
      switch self {
      case .noDefaultArgument:
        "No default value provided."
      case .applyOnlyToVar:
        "Apply only to var."
      case .missingAnnotation:
        "No annotation provided."
      case .notAnIdentifier:
        "Identifier is not valid."
      }
    }

    var diagnosticID: MessageID {
      MessageID(domain: "EnvironmentValueMacro", id: rawValue)
    }
  }
}

extension EnvironmentValueMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {

    guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
      return []
    }

    guard varDecl.bindingSpecifier.tokenKind == .keyword(.var) else {
      context.diagnose(Diagnostic(node: Syntax(node), message: Message.applyOnlyToVar))
      return []
    }

    guard var binding = varDecl.bindings.first?.as(PatternBindingSyntax.self) else {
      context.diagnose(Diagnostic(node: Syntax(node), message: Message.missingAnnotation))
      return []
    }

    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
      context.diagnose(Diagnostic(node: Syntax(node), message: Message.notAnIdentifier))
      return []
    }

    binding.pattern = PatternSyntax(
      IdentifierPatternSyntax(identifier: .identifier("defaultValue")))

    let isOptionalType = binding.typeAnnotation?.type.is(OptionalTypeSyntax.self) ?? false
    let hasDefaultValue = binding.initializer != nil

    guard isOptionalType || hasDefaultValue else {
      context.diagnose(Diagnostic(node: Syntax(node), message: Message.noDefaultArgument))
      return []
    }

    return [
      """
      private struct \(raw: identifier.capitalized)EnvironmentKey: EnvironmentKey {
          static var \(binding)
      }
      """
    ]
  }
}

extension EnvironmentValueMacro: AccessorMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AccessorDeclSyntax] {

    guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
      return []
    }

    guard varDecl.bindingSpecifier.tokenKind == .keyword(.var) else {
      context.diagnose(Diagnostic(node: Syntax(node), message: Message.applyOnlyToVar))
      return []
    }

    guard let binding = varDecl.bindings.first?.as(PatternBindingSyntax.self) else {
      context.diagnose(Diagnostic(node: Syntax(node), message: Message.missingAnnotation))
      return []
    }

    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
      context.diagnose(Diagnostic(node: Syntax(node), message: Message.notAnIdentifier))
      return []
    }

    let statement = "self[\(identifier.capitalized)EnvironmentKey.self]"
    return [
      """
      get {
         \(raw: statement)
      }
      """,
      """
      set {
         \(raw: statement) = newValue
      }
      """,
    ]
  }
}

public struct EnvironmentValuesMacro: MemberAttributeMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.AttributeSyntax] {

    guard let variable = member.as(VariableDeclSyntax.self),
      variable.bindingSpecifier.tokenKind == .keyword(.var)
    else {
      return []
    }

    return [.init("EnvironmentValue")]
  }
}
