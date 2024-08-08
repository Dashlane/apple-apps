enum ImportMethodDeeplink {

  enum Method: String {
    case csv
    case dash
    case lastpass
  }

  case `import`(Method)

  var rawValue: String {
    switch self {
    case .import(let method):
      return "import-methods/?import=\(method.rawValue)"
    }
  }

  init?(pathComponents: [String], queryParameters: [String: String]?) {
    if pathComponents.contains("import-methods"),
      let importMethod = queryParameters?["import"],
      let method = Method(rawValue: importMethod)
    {
      self = .import(method)
      return
    }

    return nil
  }
}
