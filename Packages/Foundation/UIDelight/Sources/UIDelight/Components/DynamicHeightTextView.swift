#if os(iOS)

import Foundation
import SwiftUI

public struct DynamicHeightTextView: UIViewRepresentable {
        public class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
        var parent: DynamicHeightTextView
        weak var textView: UITextView?
        var constraint: NSLayoutConstraint?

        init(_ uiTextView: DynamicHeightTextView) {
            self.parent = uiTextView
        }

        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        public func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.updateTextViewHeight(textView)

                self.parent.text = textView.text
                textView.sizeToFit()
            }
        }

        func updateTextViewHeight(_ textView: UITextView) {
            guard textView.superview != nil else {
                return
            }

            let size = textView.sizeThatFits(CGSize(width: textView.contentSize.width, height: .greatestFiniteMagnitude))
            parent.height = size.height
        }

    }

        @Binding
    var text: String
    @Binding
    var height: CGFloat?

    let isEditable: Bool
    let isSelectable: Bool
    let placeholder: String

    public init(text: Binding<String>,
                isEditable: Bool,
                isSelectable: Bool = true,
                placeholder: String,
                _ height: Binding<CGFloat?>) {
        self._text = text
        self.isEditable = isEditable
        self.isSelectable = isSelectable
        self.placeholder = placeholder
        self._height = height
    }

        public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.layoutManager.delegate = context.coordinator
        context.coordinator.constraint?.priority = .fittingSizeLevel
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.showsHorizontalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = isSelectable
        textView.dataDetectorTypes = []
        textView.backgroundColor = UIColor.clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.delegate = context.coordinator

        return textView
    }

    public func updateUIView(_ textView: UITextView, context: Context) {
        if !isEditable && text.isEmpty {
            textView[\.text] = placeholder
        } else if textView.text != text {
            textView[\.text] = text
        }
        textView[\.isEditable] = isEditable

        let maxDataLength = 10000
        textView[\.dataDetectorTypes] = text.count < maxDataLength ? .all : []

        DispatchQueue.main.async {
                        if self.height == nil && textView.superview != nil {
                context.coordinator.updateTextViewHeight(textView)
            }
        }
    }
}
#endif
