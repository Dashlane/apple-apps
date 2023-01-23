import DesignSystem
import SwiftUI
import UIDelight

struct AddBarButton: View {
    
    enum Style {
        case classic
        case circle
    }
    
    let style: Style
    let action: () -> Void
    
    init(style: Style = .classic, action: @escaping () -> Void) {
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            buttonView
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0))
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    var buttonView: some View {
        switch style {
        case .classic:
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 18, height: 18)
                .foregroundColor(.ds.text.brand.standard)
        case .circle:
            Image(asset: FiberAsset.add)
                .foregroundColor(Color(asset: FiberAsset.accentColor))
        }
    }
}

struct AddBarButton_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AddBarButton(action: {})
            .padding()
            AddBarButton(style: .circle, action: {})
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
