#if os(macOS)
    import SwiftUI

    struct TextViewWrapper: NSViewRepresentable {
        final class InternalTextView: NSTextView {
            var maxLayoutWidth: CGFloat {
                get { textContainer?.containerSize.width ?? 0 }
                set {
                    guard textContainer?.containerSize.width != newValue else { return }
                    textContainer?.containerSize.width = newValue
                    invalidateIntrinsicContentSize()
                }
            }

            override var intrinsicContentSize: NSSize {
                guard maxLayoutWidth > 0,
                      let textContainer = self.textContainer,
                      let layoutManager = self.layoutManager
                else {
                    return super.intrinsicContentSize
                }

                layoutManager.ensureLayout(for: textContainer)
                return layoutManager.usedRect(for: textContainer).size
            }
        }

        final class Coordinator: NSObject, NSTextViewDelegate {
            var openURL: OpenURLAction?

            func textView(_: NSTextView, clickedOnLink link: Any, at _: Int) -> Bool {
                guard let url = (link as? URL) ?? (link as? String).flatMap(URL.init(string:)) else {
                    return false
                }

                openURL?(url)
                return false
            }
        }

        let attributedText: NSAttributedString
        let linkForegroundColor: Color
        let maxLayoutWidth: CGFloat
        let textViewStore: TextViewStore

        func makeNSView(context: Context) -> InternalTextView {
            let nsView = InternalTextView(frame: .zero)

            nsView.drawsBackground = false
            nsView.textContainerInset = .zero
            nsView.isEditable = false
            nsView.isRichText = false
            nsView.linkTextAttributes = [
                .underlineStyle: 1,
                .foregroundColor: NSColor(linkForegroundColor)
            ]
            nsView.textContainer?.lineFragmentPadding = 0
                        nsView.textContainer?.widthTracksTextView = false
            nsView.delegate = context.coordinator

            return nsView
        }

        func updateNSView(_ nsView: InternalTextView, context: Context) {
            nsView.textStorage?.setAttributedString(attributedText)
            nsView.maxLayoutWidth = maxLayoutWidth

            nsView.textContainer?.maximumNumberOfLines = context.environment.lineLimit ?? 0
            nsView.textContainer?.lineBreakMode = NSLineBreakMode(truncationMode: context.environment.truncationMode)

            context.coordinator.openURL = context.environment.openURL

            textViewStore.didUpdateTextView(nsView)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }
    }
#endif
