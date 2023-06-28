import SwiftUI

public struct Library: LibraryContentProvider {
    public var views: [LibraryItem] {
        [
            LibraryItem(RoundedButton("Title", action: {}), title: "Rounded Button", category: .control),
            LibraryItem(
                Infobox(title: "Title", description: "Description", buttons: {
                    Button("Primary Button", action: {})
                    Button("Secondary Button", action: {})
                }),
                title: "Infobox",
                category: .control
            ),
            LibraryItem(Badge("Label", icon: .ds.lock.outlined), title: "Badge", category: .control)
        ]
    }

    @LibraryContentBuilder
    public func modifiers(base: Infobox) -> [LibraryItem] {
        LibraryItem(
            base.infoboxButtonStyle(.standaloneSecondaryButton),
            title: "Infobox Button Style",
            category: .effect
        )
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
            )
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
                        TextFieldAction.Button("Copy", image: .ds.action.copy.outlined) {
                                                    }
                    }, feedback: {
                        TextFieldTextualFeedback("An important information.")
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
                        TextFieldAction.Button("Copy", image: .ds.action.copy.outlined) {
                                                    }
                    }, feedback: {
                        TextFieldTextualFeedback("An important information.")
                    }
                ),
                title: "PasswordField",
                category: .control
            )
        ]
    }

    @LibraryContentBuilder
    public func modifiers(base: some View) -> [LibraryItem] {
        [
            LibraryItem(
                base.textFieldDisableLabelPersistency(),
                title: "Disable TextField Label Persistency",
                category: .effect
            ),
            LibraryItem(
                base.textFieldAppearance(.grouped),
                title: "TextField Appearance",
                category: .effect
            ),
            LibraryItem(
                base.textFieldFeedbackAppearance(.error),
                title: "TextField Feedback Appearance",
                category: .effect
            ),
            LibraryItem(
                base.textFieldColorHighlightingMode(.url),
                title: "TextField Color Highlighting Mode",
                category: .effect
            ),
            LibraryItem(
                base.onRevealSecureValue({ }),
                title: "TextField onRevealSecureValue callback",
                category: .other
            )
        ]
    }
}
#endif
