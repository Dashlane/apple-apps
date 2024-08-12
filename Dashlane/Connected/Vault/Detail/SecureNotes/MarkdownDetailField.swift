import CoreLocalization
import MarkdownUI
import SwiftUI
import VaultKit

struct MarkdownDetailField: View, CopiableDetailField {

  private let content: String

  init(_ content: String) {
    self.content = content
  }

  var body: some View {
    Markdown(content)
  }

  public var copiableValue: Binding<String> {
    return .constant(content)
  }

  public var title: String {
    CoreLocalization.L10n.Core.KWSecureNoteIOS.content
  }

  var fiberFieldType: VaultKit.DetailFieldType {
    return .content
  }
}

#Preview {
  MarkdownDetailField(
    """
    # Title
    Content
    """)
}
