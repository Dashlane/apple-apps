import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct PersonalDataMacro {
  enum Message: String, DiagnosticMessage {
    case notAStruct

    var diagnosticID: MessageID { .init(domain: "PersonalDataMacro", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
    var message: String {
      switch self {
      case .notAStruct:
        return "_"
      }
    }
  }
}

extension PersonalDataMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let typeDecl = declaration.as(StructDeclSyntax.self) else {
      context.diagnose(
        .init(
          node: declaration._syntaxNode,
          message: MacroExpansionErrorMessage("_")))
      return []
    }

    let contentType = retrieveContentType(of: node, attachedTo: typeDecl)

    let hasIdVariable = typeDecl.memberBlock.members.contains { member in
      guard let decl = member.decl.as(VariableDeclSyntax.self),
        !decl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) })
      else {
        return false
      }

      return decl.name() == "id"
    }

    let variables = makeInstanceVariables(structDecl: typeDecl, contentType: contentType)
    let changeContentStruct = try makeHistoryChangeContentStruct(variables: variables)

    return [
      changeContentStruct?.as(DeclSyntax.self),
      "public static let contentType = PersonalDataContentType(rawValue: \"\(raw: contentType)\")!",
      hasIdVariable ? nil : "public let id: Identifier",
      "public let metadata: RecordMetadata",
    ].compactMap { $0 }
  }
}

extension PersonalDataMacro: ExtensionMacro {
  struct Variable {
    let name: String
    let keyPath: String
    let hasCodingKey: Bool
    let searchable: Bool
    let stored: Bool
    let triggerHistory: Bool
    let isJSONEncoded: Bool
    let exceptionAttribute: OnSyncAttribute?
    let decl: VariableDeclSyntax
  }

  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {

    guard let typeDecl = declaration.as(StructDeclSyntax.self) else {
      context.diagnose(
        .init(
          node: declaration._syntaxNode,
          message: MacroExpansionErrorMessage("_")))
      return []
    }
    let structName = typeDecl.name.trimmed

    let contentType = retrieveContentType(of: node, attachedTo: typeDecl)
    let variables = makeInstanceVariables(structDecl: typeDecl, contentType: contentType)
    guard validate(variables, forContentType: contentType, macroNode: node, in: context) else {
      return []
    }

    var extensions: [ExtensionDeclSyntax] = [
      try ExtensionDeclSyntax("extension \(structName): PersonalDataCodable") {
        try makeCodingKeys(variables: variables) {
          if !variables.contains(where: { $0.name == "id" }) {
            try EnumCaseDeclSyntax("case id")
              .with(\.trailingTrivia, .newlines(1))
          }

          try EnumCaseDeclSyntax("case metadata")
            .with(\.trailingTrivia, .newlines(1))
        }

        if let exceptions = try makeXMLExceptions(variables: variables) {
          exceptions
        }
      }
    ]

    if let searchableFields = try makeSearchableFields(variables: variables) {
      extensions.append(
        try ExtensionDeclSyntax("extension \(structName): Searchable") {
          searchableFields
        })
    }

    if variables.contains(where: { $0.triggerHistory }) {
      extensions.append(
        try ExtensionDeclSyntax("extension \(structName): HistoryChangeTracking") {

        })
    }

    if variables.contains(where: { $0.name == "secured" }) {
      extensions.append(
        try ExtensionDeclSyntax("extension \(structName): SecureItem") {

        })
    }

    return extensions
  }

  static func retrieveContentType(of node: AttributeSyntax, attachedTo structDecl: StructDeclSyntax)
    -> String
  {
    return
      if let contentType = node.arguments?
      .as(LabeledExprListSyntax.self)?
      .first?
      .expression.as(StringLiteralExprSyntax.self)?.segments.description
    {
      contentType
    } else {
      structDecl.name.trimmed.description.uppercased()
    }
  }

  static func makeInstanceVariables(structDecl: StructDeclSyntax, contentType: String) -> [Variable]
  {
    let triggerHistoryKeys = PersonalDataSpec.triggerHistoryKeys[contentType, default: []]

    return structDecl.memberBlock.members.compactMap { member -> VariableDeclSyntax? in

      guard let decl = member.decl.as(VariableDeclSyntax.self),
        !decl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) })
      else {
        return nil
      }

      return decl
    }.map { variable in
      let name = variable.name()!
      let codingKey = CodingKeyAttribute(from: variable)
      let keyPath = codingKey?.value ?? name
      let searchable = SearchableAttribute(from: variable) != nil
      let exceptionAttribute = OnSyncAttribute(from: variable)
      let isJSONEncoded = variable.hasAttribute("JSONEncoded")
      let stored = variable.isStoredProperty
      let triggerHistory = triggerHistoryKeys.contains(keyPath)

      return Variable(
        name: name,
        keyPath: keyPath,
        hasCodingKey: codingKey != nil,
        searchable: searchable,
        stored: stored,
        triggerHistory: triggerHistory,
        isJSONEncoded: isJSONEncoded,
        exceptionAttribute: exceptionAttribute,
        decl: variable)
    }
  }

  static func validate(
    _ variables: [Variable],
    forContentType contentType: String,
    macroNode: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> Bool {
    let keys = PersonalDataSpec.keys[contentType, default: []]
    guard !keys.isEmpty else {
      context.diagnose(
        .unknownTransactionType(
          contentType,
          expected: PersonalDataSpec.keys.keys.sorted(),
          node: macroNode))
      return false
    }

    let jsonKeys = PersonalDataSpec.jsonKeys[contentType, default: []]

    for variable in variables where variable.stored {
      if !keys.contains(variable.keyPath) && variable.exceptionAttribute == nil {
        context.diagnose(
          .unknownPropertyKey(
            variable.name,
            expected:
              keys
              .subtracting(variables.map(\.keyPath))
              .sorted(), variable: variable))
      }

      if jsonKeys.contains(variable.keyPath) && !variable.isJSONEncoded {
        context.diagnose(.missingJSONAttribute(on: variable))
      }
    }

    return true
  }

  static func makeCodingKeys(
    variables: [Variable],
    @MemberBlockItemListBuilder extraCases: () throws -> MemberBlockItemListSyntax?
  ) throws -> EnumDeclSyntax {
    let clause = InheritanceClauseSyntax {
      InheritedTypeSyntax(type: "String" as TypeSyntax)
      InheritedTypeSyntax(type: "CodingKey" as TypeSyntax)
    }

    return try EnumDeclSyntax(name: "CodingKeys", inheritanceClause: clause) {
      if let cases = try extraCases() {
        cases
      }

      for variable in variables where variable.stored {
        if variable.hasCodingKey {
          try EnumCaseDeclSyntax("case \(raw: variable.name) = \"\(raw: variable.keyPath)\"")
            .with(\.trailingTrivia, .newlines(1))
        } else {
          try EnumCaseDeclSyntax("case \(raw: variable.name)")
            .with(\.trailingTrivia, .newlines(1))
        }
      }
    }.with(\.trailingTrivia, .newlines(2))
  }

  static func makeXMLExceptions(variables: [Variable]) throws -> VariableDeclSyntax? {
    let exceptions = variables.compactMap { variable -> String? in
      guard variable.stored, let exceptionAttribute = variable.exceptionAttribute else {
        return nil
      }

      return "CodingKeys.\(variable.name).stringValue: \(exceptionAttribute.arguments)"
    }

    guard !exceptions.isEmpty else {
      return nil
    }

    return try VariableDeclSyntax("public static var xmlRuleExceptions: [String: XMLRuleException]")
    {
      """
      [
        \(raw: exceptions.joined(separator: ","))
      ]
      """
    }
  }

  static func makeSearchableFields(variables: [Variable]) throws -> VariableDeclSyntax? {
    let searchableFields =
      variables
      .filter(\.searchable)
      .map(\.name)

    guard !searchableFields.isEmpty else {
      return nil
    }

    return try VariableDeclSyntax("public var searchValues: [SearchValueConvertible]") {
      """
      [
        \(raw: searchableFields.joined(separator: ","))
      ]
      """
    }
  }

  static func makeHistoryChangeContentStruct(variables: [Variable]) throws -> StructDeclSyntax? {
    let variables =
      variables
      .filter(\.triggerHistory)

    guard !variables.isEmpty else {
      return nil
    }

    return try StructDeclSyntax("public struct PreviousChangeContent: HistoryChangePreviousContent")
    {
      try makeCodingKeys(variables: variables) {}

      for variable in variables {
        variable.decl.asMutatableOptional()
      }
    }
  }
}

extension VariableDeclSyntax {

  func asMutatableOptional() -> VariableDeclSyntax {
    let baseType = type!
    let type: TypeSyntaxProtocol =
      baseType.is(OptionalTypeSyntax.self) ? baseType : OptionalTypeSyntax(wrappedType: baseType)

    return VariableDeclSyntax(
      leadingTrivia: .newline,
      attributes: attributes.with(\.leadingTrivia, []),
      modifiers: modifiers,
      .var,
      name: patternSyntax!,
      type: TypeAnnotationSyntax(type: type),
      initializer: nil)
  }

  public var type: TypeSyntax? {
    return bindings.lazy.compactMap(\.typeAnnotation).first?.type
  }
  public var patternSyntax: PatternSyntax? {
    return bindings.first?.pattern
  }

}
