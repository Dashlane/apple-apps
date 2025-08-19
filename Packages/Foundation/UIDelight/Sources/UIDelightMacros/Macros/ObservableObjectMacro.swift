import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservableObjectMacro {
  enum Message: String, DiagnosticMessage {
    case notAClass

    var diagnosticID: MessageID { .init(domain: "ObservableObjectMacro", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
    var message: String {
      switch self {
      case .notAClass:
        return "_"
      }
    }
  }
}

extension ObservableObjectMacro: MemberAttributeMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.AttributeSyntax] {

    guard let variable = member.as(VariableDeclSyntax.self),
      variable.isStored,
      variable.bindingSpecifier.tokenKind == .keyword(.var),
      !variable.hasAttributes("ObservationIgnored")
    else {
      return []
    }

    return [.init("Published")]
  }
}

extension ObservableObjectMacro: ExtensionMacro {
  struct ClassDiagnostic: DiagnosticMessage {
    let diagnosticID = MessageID(domain: "ObservableObjectMacro", id: "class")
    let severity: DiagnosticSeverity = .error
    let message: String = "_"
  }

  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
    conformingTo protocols: [SwiftSyntax.TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {

    guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
      context.diagnose(.init(node: declaration._syntaxNode, message: Message.notAClass))
      return []
    }

    return [
      try ExtensionDeclSyntax(
        "extension \(classDecl.name.trimmed): ObservableObject",
        membersBuilder: {

        })
    ]
  }
}
