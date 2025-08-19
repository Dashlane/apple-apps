import SwiftUI

@attached(member, names: named(init))
public macro ViewInit() = #externalMacro(module: "UIDelightMacros", type: "ViewInitMacro")

@attached(memberAttribute)
@attached(extension, conformances: ObservableObject)
public macro ObservableObject() =
  #externalMacro(module: "UIDelightMacros", type: "ObservableObjectMacro")
