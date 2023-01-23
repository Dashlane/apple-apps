import SwiftUI

struct Library: LibraryContentProvider {
    var views: [LibraryItem] {
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
    func modifiers(base: Infobox) -> [LibraryItem] {
        LibraryItem(
            base.infoboxButtonStyle(.standaloneSecondaryButton),
            title: "Infobox Button Style",
            category: .effect
        )
    }

    @LibraryContentBuilder
    func modifiers(base: some View) -> [LibraryItem] {
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
struct ContrainedLibrary: LibraryContentProvider {
    var views: [LibraryItem] {
        LibraryItem(TextInput("Placeholder", text: .constant("")), title: "TextInput", category: .control)
    }
}
#endif
