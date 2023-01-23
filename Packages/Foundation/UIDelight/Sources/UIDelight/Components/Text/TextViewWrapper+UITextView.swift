#if canImport(UIKit)
    import SwiftUI

    struct TextViewWrapper: UIViewRepresentable {
        final class InternalTextView: UITextView {
            var maxLayoutWidth: CGFloat = 0 {
                didSet {
                    guard maxLayoutWidth != oldValue else { return }
                    invalidateIntrinsicContentSize()
                }
            }

            override var intrinsicContentSize: CGSize {
                guard maxLayoutWidth > 0 else {
                    return super.intrinsicContentSize
                }

                return sizeThatFits(
                    CGSize(width: maxLayoutWidth, height: .greatestFiniteMagnitude)
                )
            }
        }

        let attributedText: NSAttributedString
        let linkForegroundColor: Color
        let maxLayoutWidth: CGFloat
        let textViewStore: TextViewStore

        func makeUIView(context: Context) -> InternalTextView {
            let view = InternalTextView()

            view.backgroundColor = .clear
            view.textContainerInset = .zero
            view.isScrollEnabled = false
            view.dataDetectorTypes = .link
            view.isEditable = false
            view.isUserInteractionEnabled = true
            view.linkTextAttributes = [
                .underlineStyle: 1,
                .foregroundColor: UIColor(linkForegroundColor)
            ]
            view.textContainer.lineFragmentPadding = 0

            return view
        }

        func updateUIView(_ textView: InternalTextView, context: Context) {
            textView.attributedText = attributedText
            textView.maxLayoutWidth = maxLayoutWidth

            textView.textContainer.maximumNumberOfLines = context.environment.lineLimit ?? 0
            textView.textContainer.lineBreakMode = NSLineBreakMode(truncationMode: context.environment.truncationMode)

            textViewStore.didUpdateTextView(textView)
        }
    }
#endif
