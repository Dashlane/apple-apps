import UIKit
import SwiftUI

struct MultilineDetailTextView: View {

    @Binding
    var text: String
    let placeholder: String
    let isSelectable: Bool
    let isEditable: Bool

    @State
    var height: CGFloat?

    init(text: Binding<String>,
         placeholder: String = "",
         isEditable: Bool,
         isSelectable: Bool = true) {
        self._text = text
        self.placeholder = placeholder
        self.isEditable = isEditable
        self.isSelectable = isSelectable
    }

    var body: some View {
        DynamicHeightTextView(text: $text,
                              isEditable: isEditable,
                              isSelectable: isSelectable,
                              placeholder: placeholder,
                              $height)
            .frame(minHeight: height, alignment: .top)
    }
}
