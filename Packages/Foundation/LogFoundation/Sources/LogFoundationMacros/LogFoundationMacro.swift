import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct LogFoundationPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    LoggableMacro.self,
    LogPublicPrivacyMacro.self,
  ]
}
