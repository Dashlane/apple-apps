import SwiftUI

@attached(member, names: named(init))
public macro ViewInit() = #externalMacro(module: "MacrosKitMacros", type: "ViewInitMacro")

@attached(memberAttribute)
@attached(extension, conformances: ObservableObject)
public macro ObservableObject() =
  #externalMacro(module: "MacrosKitMacros", type: "ObservableObjectMacro")

@attached(peer, names: arbitrary)
@attached(accessor, names: named(get), named(set))
public macro EnvironmentValue() =
  #externalMacro(module: "MacrosKitMacros", type: "EnvironmentValueMacro")

@attached(memberAttribute)
public macro EnvironmentValues() =
  #externalMacro(module: "MacrosKitMacros", type: "EnvironmentValuesMacro")
