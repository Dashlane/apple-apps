import Foundation

public struct AlertSection: Sendable {

  public struct Title: Sendable {
    public internal(set) var data: String

    init(_ string: String) {
      self.data = string
    }
  }

  public internal(set) var title: Title
  public internal(set) var contents: [String] = []

  public func string() -> String {
    return String(format: title.data, arguments: contents as [CVarArg])
  }

  public func attributedString(withContentAttributes attributes: AttributeContainer)
    -> AttributedString
  {
    var attributedString = AttributedString(self.string())
    for content in contents {
      guard let contentRange = attributedString.range(of: content) else {
        continue
      }
      attributedString[contentRange].mergeAttributes(attributes, mergePolicy: .keepNew)
    }

    return attributedString
  }

  public func attributedString(
    withContentJoinedBy separator: String, attributes: AttributeContainer
  ) -> AttributedString {
    let content = contents.joined(separator: ", ")
    var attributedString = AttributedString(String(format: title.data, content))

    guard let contentRange = attributedString.range(of: content) else {
      return attributedString
    }

    attributedString[contentRange].mergeAttributes(attributes, mergePolicy: .keepNew)

    return attributedString
  }

  public func attributedString(
    withContentAttributes attributes: AttributeContainer, splittedBy delimiter: String
  ) -> AttributedString {

    var reversedContents: [String] = contents.reversed()
    let components = title.data.components(separatedBy: delimiter)
    let filledTitle = components.reduce("") { (result, str) -> String in
      guard let content = reversedContents.popLast() else {
        return result
      }
      return result.appending(str.appending(content))
    }

    var attributedString = AttributedString(filledTitle)

    for content in contents {
      guard let contentRange = attributedString.range(of: content) else {
        continue
      }

      attributedString[contentRange].mergeAttributes(attributes, mergePolicy: .keepNew)
    }

    return attributedString
  }
}
