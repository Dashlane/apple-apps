import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ViewInitMacro: MemberMacro {
  enum Message: String, DiagnosticMessage {
    case notAStruct
    case explicitAnotation

    var diagnosticID: MessageID { .init(domain: "ViewInitMacro", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
    var message: String {
      switch self {
      case .notAStruct:
        return "_"
      case .explicitAnotation:
        return "_"
      }
    }
  }

  public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
    of node: AttributeSyntax,
    providingMembersOf declaration: Declaration,
    in context: Context
  ) throws -> [DeclSyntax] {
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      context.diagnose(.init(node: declaration._syntaxNode, message: Message.notAStruct))
      return []
    }

    var included: [(variable: VariableDeclSyntax, wrapper: SwiftUIPropertyWrapper?)] = []

    for property in structDecl.storedProperties {
      let wrapper = property.swiftUIPropertyWrapper()
      guard wrapper?.shouldIncludeInInit != false, !property.isFixed else {
        continue
      }

      if property.type != nil {
        included.append((property, wrapper))
      } else {
        context.diagnose(.init(node: property._syntaxNode, message: Message.explicitAnotation))
      }
    }

    guard !included.isEmpty else { return [] }

    let signature = FunctionSignatureSyntax(
      parameterClause: FunctionParameterClauseSyntax(parametersBuilder: {
        for property in included {
          if let type = property.variable.type {
            let param =
              switch property.wrapper {
              case .stateObject:
                "\(property.variable.identifier)_\(type.type.trimmed)"
              case .binding, .focusedBinding, .bindable:
                "\(property.variable.identifier): \(property.wrapper!.rawValue)<\(type.type.trimmed)>"
              case .viewBuilder:
                "_\(property.variable.identifier)_\(type.type.trimmed)"
              default:
                "\(property.variable.bindings)"
              }

            FunctionParameterSyntax(stringLiteral: param)
          }
        }
      }))

    let generatedInit = InitializerDeclSyntax(signature: signature) {
      for property in included {
        let identifier = property.variable.identifier
        switch property.wrapper {
        case .state, .gestureState:
          "self._\(identifier) = .init(initialValue: \(identifier))"
        case .observedObject:
          "self._\(identifier) = .init(wrappedValue: \(identifier))"
        case .stateObject:
          "self._\(identifier) = .init(wrappedValue: \(identifier)())"
        case .binding, .focusedBinding, .bindable:
          "self._\(identifier) = \(identifier)"
        default:
          "self.\(identifier) = \(identifier)"
        }
      }
    }

    return [
      DeclSyntax(generatedInit)
    ]
  }
}

enum SwiftUIPropertyWrapper: String {
  static var ignored: Set<SwiftUIPropertyWrapper> = [
    .focusState,
    .namespace,
    .environment,
    .environmentObject,
    .scaledMetric,
    .appStorage,
    .sceneStorage,
  ]

  case viewBuilder = "ViewBuilder"
  case state = "State"
  case gestureState = "GestureState"
  case stateObject = "StateObject"
  case binding = "Binding"
  case bindable = "Bindable"
  case observedObject = "ObservedObject"
  case environmentObject = "EnvironmentObject"
  case environment = "Environment"
  case focusState = "FocusState"
  case focusedBinding = "FocusedBinding"
  case namespace = "Namespace"
  case scaledMetric = "ScaledMetric"
  case accessibilityFocusState = "AccessibilityFocusState"
  case appStorage = "AppStorage"
  case sceneStorage = "SceneStorage"

  var shouldIncludeInInit: Bool {
    return !SwiftUIPropertyWrapper.ignored.contains(self)
  }
}

extension VariableDeclSyntax {
  func swiftUIPropertyWrapper() -> SwiftUIPropertyWrapper? {
    guard let name = firstAttributeName() else {
      return nil
    }

    return SwiftUIPropertyWrapper(rawValue: name)
  }

}
