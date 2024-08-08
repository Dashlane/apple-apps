import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacroExpansion

extension Diagnostic {
  struct CustomMessageFix: FixItMessage, Error {
    let fixItID: SwiftDiagnostics.MessageID
    let message: String

    init(_ message: String, id: MessageID) {
      self.message = message
      self.fixItID = id
    }
  }
}

extension Diagnostic {
  static func unknownTransactionType(
    _ type: String,
    expected: [String],
    node: AttributeSyntax
  ) -> Diagnostic {

    let fixIts: [FixIt] = expected.map { type in

      FixIt(
        message: MacroExpansionFixItMessage("Use \(type)"),
        changes: [
          .replace(
            oldNode: Syntax(node),
            newNode: Syntax(
              ExprSyntax("_\(raw: type)\")")
                .with(\.leadingTrivia, node.leadingTrivia)
                .with(\.trailingTrivia, node.trailingTrivia)))
        ])

    }

    return Diagnostic(
      node: node,
      message: MacroExpansionErrorMessage("Unknown content type \(type)"),
      fixIts: fixIts)
  }
}
extension Diagnostic {
  static func unknownPropertyKey(
    _ key: String, expected: [String], variable: PersonalDataMacro.Variable
  ) -> Diagnostic {
    let variableWithSkip = variable.decl
      .withAtribute(AttributeSyntax("OnSync", expression: ExprSyntax(".skip")))

    var fixIts = [
      FixIt(
        message: MacroExpansionFixItMessage("Skip during sync"),
        changes: [
          .replace(oldNode: Syntax(variable.decl), newNode: Syntax(variableWithSkip))
        ]),
      FixIt(
        message: MacroExpansionFixItMessage("Remove property"),
        changes: [
          .replace(oldNode: Syntax(variable.decl), newNode: Syntax("" as DeclSyntax))
        ]),
    ]

    if !variable.hasCodingKey {
      for key in expected {
        let variableWithCodingKey = variable.decl
          .withAtribute(AttributeSyntax("CodingKey", expression: ExprSyntax("\"\(raw: key)\"")))

        fixIts.append(
          FixIt(
            message: MacroExpansionFixItMessage("Use coding key \"\(key)\""),
            changes: [
              .replace(oldNode: Syntax(variable.decl), newNode: Syntax(variableWithCodingKey))
            ])
        )
      }
    }

    return Diagnostic(
      node: variable.decl.bindings,
      message: MacroExpansionErrorMessage("Unknown key \(key)"),
      fixIts: fixIts)
  }

  static func missingJSONAttribute(on variable: PersonalDataMacro.Variable) -> Diagnostic {
    let variableWithJSON = variable.decl
      .withAtribute(AttributeSyntax("_"))

    return Diagnostic(
      node: variable.decl.bindings,
      message: MacroExpansionErrorMessage("\"\(variable.name)\" should be encoded as JSON"),
      fixIt: FixIt(
        message: MacroExpansionFixItMessage("_"),
        changes: [
          .replace(oldNode: Syntax(variable.decl), newNode: Syntax(variableWithJSON))
        ]))
  }

}

extension VariableDeclSyntax {
  func withAtribute(_ newAttribute: AttributeSyntax) -> VariableDeclSyntax {
    var attributes = self.attributes
    let trailing = attributes.trailingTrivia
    attributes.trailingTrivia = []
    attributes.append(
      AttributeListSyntax.Element(newAttribute)
        .with(\.leadingTrivia, .newline))
    attributes.trailingTrivia = trailing

    if self.attributes.isEmpty {
      return with(\.leadingTrivia, .newline)
        .with(\.attributes, attributes.with(\.leadingTrivia, self.leadingTrivia))
    } else {
      return with(\.attributes, attributes)
    }
  }
}

extension AttributeSyntax {
  init(_ name: TypeSyntax, expression: ExprSyntax) {
    self.init(
      name,
      argumentList: {
        LabeledExprSyntax(expression: expression)
      })
  }
}
