import SwiftUI

public struct MarkdownText: View {
  private let attributedText: AttributedString

  public init(_ markdown: String) {
    self.attributedText =
      (try? AttributedString(styledMarkdown: markdown)) ?? AttributedString(markdown)
  }

  public var body: some View {
    Text(attributedText)
  }
}

struct MarkdownText_Previews: PreviewProvider {
  static var previews: some View {
    MarkdownText("Text with **bold** area")
  }
}

extension AttributedString {
  init(styledMarkdown markdownString: String) throws {
    var output = try AttributedString(
      markdown: markdownString,
      options: .init(
        allowsExtendedAttributes: true,
        interpretedSyntax: .inlineOnlyPreservingWhitespace,
        failurePolicy: .returnPartiallyParsedIfPossible
      ),
      baseURL: nil
    )

    for (intentBlock, intentRange) in output.runs[
      AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self
    ].reversed() {
      guard let intentBlock = intentBlock else { continue }
      for intent in intentBlock.components {
        switch intent.kind {
        case .header(let level):
          switch level {
          case 1:
            output[intentRange].font = .system(.title).bold()
          case 2:
            output[intentRange].font = .system(.title2).bold()
          case 3:
            output[intentRange].font = .system(.title3).bold()
          default:
            break
          }
        default:
          break
        }
      }

      if intentRange.lowerBound != output.startIndex {
        output.characters.insert(contentsOf: "\n", at: intentRange.lowerBound)
      }
    }

    self = output

  }
}
