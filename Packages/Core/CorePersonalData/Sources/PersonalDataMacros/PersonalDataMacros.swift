import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct PersonalDataMacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    PersonalDataMacro.self,
    CodingKeyAttribute.self,
    OnSyncAttribute.self,
    SearchableAttribute.self,
  ]
}
