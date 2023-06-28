import SwiftUI
import DesignSystem

struct CloseButton: View {
    let action: () -> Void
    var body: some View {
       #if DEBUG
          button
            .accessibilityLabel("cross")
       #else
          button
       #endif
    }

    var button: some View {
        Button(action: action, label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 26, height: 26)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.ds.border.neutral.standard.hover)
        })
    }
}

struct CloseIcon_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton {}
    }
}
