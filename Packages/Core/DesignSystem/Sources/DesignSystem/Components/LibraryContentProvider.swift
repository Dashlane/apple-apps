import SwiftUI

public struct Library: LibraryContentProvider {
  public var views: [LibraryItem] {
    [
      LibraryItem(
        Infobox("Title", description: "Description") {
          Button("Primary Button", action: {})
          Button("Secondary Button", action: {})
        },
        title: "Infobox",
        category: .control
      ),
      LibraryItem(Badge("Label", icon: .ds.lock.outlined), title: "Badge", category: .control),
    ]
  }

  @LibraryContentBuilder
  public func modifiers(base: some View) -> [LibraryItem] {
    [
      LibraryItem(
        base.style(mood: .positive, intensity: .quiet),
        title: "Component Style",
        category: .effect
      ),
      LibraryItem(
        base.iconAlignment(.trailing),
        title: "Component Icon Alignment",
        category: .effect
      ),
    ]
  }
}

#if canImport(UIKit)
  public struct ContrainedLibrary: LibraryContentProvider {
    public var views: [LibraryItem] {
      [
        LibraryItem(
          DS.TextField(
            "Label",
            placeholder: "Placeholder",
            text: .constant(""),
            actions: {
              FieldAction.Button("Copy", image: .ds.action.copy.outlined) {
              }
            },
            feedback: {
              FieldTextualFeedback("An important information.")
            }
          ),
          title: "TextField",
          category: .control
        ),
        LibraryItem(
          DS.PasswordField(
            "Label",
            placeholder: "Placeholder",
            text: .constant(""),
            actions: {
              FieldAction.Button("Copy", image: .ds.action.copy.outlined) {
              }
            },
            feedback: {
              FieldTextualFeedback("An important information.")
            }
          ),
          title: "PasswordField",
          category: .control
        ),
      ]
    }

    @LibraryContentBuilder
    public func modifiers(base: some View) -> [LibraryItem] {
      [
        LibraryItem(
          base.fieldLabelPersistencyDisabled(),
          title: "Disable Field Label Persistency",
          category: .effect
        ),
        LibraryItem(
          base.fieldAppearance(.grouped),
          title: "TextField Appearance",
          category: .effect
        ),
        LibraryItem(
          base.style(.error),
          title: "TextField Feedback Appearance",
          category: .effect
        ),
        LibraryItem(
          base.textColorHighlightingMode(.url),
          title: "TextField Color Highlighting Mode",
          category: .effect
        ),
        LibraryItem(
          base.onRevealSecureValue({}),
          title: "TextField onRevealSecureValue callback",
          category: .other
        ),
      ]
    }
  }
#endif
