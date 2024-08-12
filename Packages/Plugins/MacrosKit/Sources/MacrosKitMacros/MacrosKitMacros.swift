import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct MacrosKitPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    ObservableObjectMacro.self,
    ViewInitMacro.self,
    EnvironmentValueMacro.self,
    EnvironmentValuesMacro.self,
  ]
}
