import SwiftUI

struct RowActionButton<Label: View>: View {
    
    let enabled: Bool
    let action: () -> Void
    let label: Label

    var body: some View {
        Button(action: action, label: {
            label
                .frame(width: 24, height: 24)
        })
        .buttonStyle(RowActionButtonStyle(enabled: enabled))
        .disabled(!enabled)
    }
}
