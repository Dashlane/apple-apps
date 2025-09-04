import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LoggableMacro {
  enum MacroError: Error {
    case incorrectType
  }

  enum Message: String, DiagnosticMessage {
    case incorrectType
    case classType

    var diagnosticID: MessageID { .init(domain: "LoggableMacro", id: rawValue) }
    var severity: DiagnosticSeverity {
      switch self {
      case .incorrectType:
        return .error
      case .classType:
        return .warning
      }
    }
    var message: String {
      switch self {
      case .incorrectType:
        return "_"
      case .classType:
        return "_"
      }
    }
  }
}

private let publicPrivacySuffix = ", privacy: .public"
private let publicAttribute = "LogPublicPrivacy"
extension LoggableMacro: ExtensionMacro {

  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
    conformingTo protocols: [SwiftSyntax.TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {

    let declSyntax: (member: CodeBlockItemListSyntax, name: String)

    if let enumDecl = declaration.as(EnumDeclSyntax.self) {
      declSyntax = (try expandEnum(enumDecl), enumDecl.name.text)
    } else if let structDecl = declaration.as(StructDeclSyntax.self) {
      declSyntax = (
        try expandStructOrClass(structDecl, typeName: structDecl.name.text), structDecl.name.text
      )
    } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
      declSyntax = (
        try expandStructOrClass(classDecl, typeName: classDecl.name.text), classDecl.name.text
      )
      context.diagnose(.init(node: declaration._syntaxNode, message: Message.classType))
    } else {
      context.diagnose(.init(node: declaration._syntaxNode, message: Message.incorrectType))
      return []
    }

    return [
      try ExtensionDeclSyntax(
        "extension \(raw: declSyntax.name): Loggable",
        membersBuilder: {
          try FunctionDeclSyntax("public func log() -> LogMessage") {
            declSyntax.member
          }
        })
    ]
  }
}

typealias AssociatedValue = (param: String?, value: String)

extension LoggableMacro {
  @CodeBlockItemListBuilder
  private static func expandEnum(_ enumDecl: EnumDeclSyntax) throws -> CodeBlockItemListSyntax {
    let enumName = enumDecl.name.text
    let cases = enumDecl.memberBlock.members.compactMap {
      member -> [(caseName: String, hasPublicPrivacy: Bool, associatedValues: [AssociatedValue]?)]?
      in
      guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { return nil }

      return caseDecl.elements.map { element in
        let caseName = element.name.text
        let associatedValues = element.associatedValues()

        return (
          caseName: caseName, hasPublicPrivacy: caseDecl.hasPublicPrivacy(),
          associatedValues: associatedValues
        )
      }
    }.flatMap { $0 }

    try SwitchExprSyntax("switch self") {
      for enumCase in cases {
        if let associatedValues = enumCase.associatedValues, !associatedValues.isEmpty {
          let params = associatedValues.map { "let \($0.value)" }.joined(separator: ", ")
          let privacySuffix = enumCase.hasPublicPrivacy ? publicPrivacySuffix : ""
          let values = associatedValues.map { associatedValue in
            let valueSyntax = "\\(\(associatedValue.value)\(privacySuffix))"
            if let paramName = associatedValue.param {
              return "\(paramName): " + valueSyntax
            } else {
              return valueSyntax
            }
          }.joined(separator: ", ")

          SwitchCaseSyntax("case .\(raw: enumCase.caseName)(\(raw: params)):") {
            "return \"\(raw: enumName).\(raw: enumCase.caseName)(\(raw: values))\""
          }
        } else {
          SwitchCaseSyntax("case .\(raw: enumCase.caseName):") {
            "return \"\(raw: enumName).\(raw: enumCase.caseName)\""
          }
        }
      }
    }
  }

}
extension EnumCaseDeclSyntax {
  func hasPublicPrivacy() -> Bool {
    return attributes.compactMap({ $0.as(AttributeSyntax.self) })
      .contains {
        $0.attributeName.as(IdentifierTypeSyntax.self)?.name.tokenKind
          == .identifier(publicAttribute)
      }
  }
}

extension EnumCaseElementSyntax {
  func associatedValues() -> [AssociatedValue]? {
    var valueNameCount = [String: Int]()

    return parameterClause?.parameters.compactMap { param in
      let paramName = param.secondName?.text ?? param.firstName?.text
      var valueName =
        paramName
        ?? param.type.description.components(separatedBy: ".").last!.onlyAlphanumeric()
        .lowercasedFirstLetter()

      let count = valueNameCount[valueName, default: 0]
      if count > 0 {
        valueName += "\(count)"
      }
      valueNameCount[valueName] = count + 1

      return (paramName, valueName)
    }
  }
}

struct Property {
  let name: String
  let hasPublicPrivacy: Bool
}

extension LoggableMacro {

  @CodeBlockItemListBuilder
  private static func expandStructOrClass(_ typeDecl: DeclGroupSyntax, typeName: String) throws
    -> CodeBlockItemListSyntax
  {

    let properties = typeDecl.properties()

    let descriptionBody = properties.map {
      let privacySuffix = $0.hasPublicPrivacy ? publicPrivacySuffix : ""
      return "\($0.name): \\(\($0.name)\(privacySuffix))"
    }.joined(separator: ", ")

    "return \"\(raw: typeName)(\(raw: descriptionBody))\""
  }
}

extension DeclGroupSyntax {
  fileprivate func properties() -> [Property] {
    var result: [Property] = []

    for member in memberBlock.members {
      guard let varDecl = member.decl.as(VariableDeclSyntax.self), !varDecl.isStatic else {
        continue
      }
      for binding in varDecl.bindings {
        guard let variableName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else {
          continue
        }

        let attribute = varDecl.attributes.compactMap({ $0.as(AttributeSyntax.self) })
          .first(where: {
            $0.attributeName.as(IdentifierTypeSyntax.self)?.name.tokenKind
              == .identifier(publicAttribute)
          })

        let hasPublicPrivacy: Bool = {
          guard attribute != nil else { return false }
          return true
        }()

        result.append(Property(name: variableName, hasPublicPrivacy: hasPublicPrivacy))
      }
    }

    return result
  }
}

extension VariableDeclSyntax {
  var isStatic: Bool {
    return modifiers.lazy.contains(where: { $0.name.tokenKind == .keyword(.static) }) == true
  }
}

extension String {
  fileprivate func lowercasedFirstLetter() -> String {
    return prefix(1).lowercased() + dropFirst()
  }
  fileprivate func onlyAlphanumeric() -> String {
    return String(
      unicodeScalars.filter { scalar in
        CharacterSet.alphanumerics.contains(scalar)
      })
  }
}
