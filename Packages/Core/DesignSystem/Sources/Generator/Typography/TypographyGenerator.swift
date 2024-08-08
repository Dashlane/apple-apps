import Foundation

struct TypographyGenerator {
  let destination: URL
  let apiToken: String

  func generate() async throws {
    print("⏳ Fetching text styles from Specify...")
    let request = URLRequest.makeSpecifyRequest(
      endpoint: .typographyTokens,
      apiToken: apiToken
    )
    let (data, _) = try await URLSession.shared.data(for: request)
    let tokens = try JSONDecoder().decodeThrowable(
      [SpecifyTypographyToken].self,
      from: data
    )

    print("✅ Fetched \(tokens.count) typography tokens from Specify.")

    let completeTokens = try await appendingFontData(to: tokens)
    try saveTokensCustomFontsToDisk(completeTokens)
    try saveTokensToDisk(tokens)
  }

  private func appendingFontData(to tokens: [SpecifyTypographyToken]) async throws
    -> [SpecifyTypographyToken]
  {
    let filteredTokens = tokens.filter(\.usesCustomFont)

    return try await withThrowingTaskGroup(of: SpecifyTypographyToken.self) { group in
      var processedPostScriptNames = Set<String>()
      for fontToken in filteredTokens {
        guard !processedPostScriptNames.contains(fontToken.fontPostScriptName)
        else { continue }
        processedPostScriptNames.insert(fontToken.fontPostScriptName)
        group.addTask {
          return try await fontToken.withFont()
        }
      }
      print("⏳ Fetching individual font data for \(processedPostScriptNames.count) fonts.")
      var newTokens = [SpecifyTypographyToken]()
      for try await token in group {
        assert(token.font != nil, "Failed to fetch associated custom font.")
        newTokens.append(token)
        print("📥 Downloaded \(token.fontPostScriptName) font.")
      }
      return newTokens
    }
  }

  private func saveTokensCustomFontsToDisk(_ tokens: [SpecifyTypographyToken]) throws {
    let fontsFolder = self.destination
      .appendingPathComponent("Resources", isDirectory: true)
      .appendingPathComponent("Fonts", isDirectory: true)

    for token in tokens {
      assert(token.font != nil, "Font data should be available at this point.")
      print("Writing \(token.fontPostScriptName).\(token.format) on disk...")
      let fontURL = fontsFolder.appendingPathComponent(
        "\(token.fontPostScriptName).\(token.format)")
      try token.font!.write(to: fontURL)
    }
  }

  private func saveTokensToDisk(_ tokens: [SpecifyTypographyToken]) throws {
    let container = NSMutableDictionary()

    for token in tokens {
      var pathComponents = token.name.components(separatedBy: "/")
      let tokenName = pathComponents.removeLast()
      var level = container
      let value: [String: Any] = [
        "name": tokenName,
        "font": token.usesCustomFont ? token.fontFamilyPath! : "-",
        "fontSize": token.fontSize,
        "fontWeight": token.fontWeight,
        "lineSpacing": token.lineHeight,
        "tracking": token.letterSpacing ?? 0,
        "nativeStyleMatch": token.nativeStyleMatch,
        "leading": token.leading,
        "usesSystemFont": token.usesSystemFont,
        "fontDesign": token.fontDesign,
        "isUppercased": token.isUppercased,
        "isUnderlined": token.isUnderlined,
        "isHeading": token.isHeading,
      ]

      for pathComponent in pathComponents {
        if pathComponent == pathComponents.last {
          if let existingArray = level[pathComponent] as? NSMutableArray {
            existingArray.add(value)
          } else {
            let array = NSMutableArray()
            array.add(value)
            level[pathComponent] = array
          }
        } else {
          if let existingContainer = level[pathComponent] as? NSMutableDictionary {
            level = existingContainer
          } else {
            let newContainer = NSMutableDictionary()
            level.setObject(newContainer, forKey: pathComponent as NSCopying)
            level = newContainer
          }
        }
      }
    }

    let outputURL =
      destination
      .appendingPathComponent("Resources", isDirectory: true)
      .appendingPathComponent("Fonts", isDirectory: true)
      .appendingPathComponent("TextStyles", isDirectory: false)
      .appendingPathExtension("plist")
    try container.write(to: outputURL)
  }
}
