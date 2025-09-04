@attached(extension, conformances: Loggable, names: named(log))
public macro Loggable() = #externalMacro(module: "LogFoundationMacros", type: "LoggableMacro")

@attached(peer)
public macro LogPublicPrivacy() =
  #externalMacro(module: "LogFoundationMacros", type: "LogPublicPrivacyMacro")
