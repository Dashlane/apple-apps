import SwiftUI

final class TextViewStore: ObservableObject {
    @Published var intrinsicContentSize: CGSize?

    func didUpdateTextView(_ textView: TextViewWrapper.InternalTextView) {
        intrinsicContentSize = textView.intrinsicContentSize
    }
}
