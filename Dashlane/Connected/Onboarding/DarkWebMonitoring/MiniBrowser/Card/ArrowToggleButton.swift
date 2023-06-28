import DesignSystem
import SwiftUI

struct ArrowToggleButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action, label: {
            HStack {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 8, height: 4, alignment: .center)
            }
            .foregroundColor(.ds.text.inverse.quiet)
        })
    }
}

struct ArrowToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        ArrowToggleButton(title: "More options",
                          action: {})
            .previewLayout(.sizeThatFits)
    }
}
