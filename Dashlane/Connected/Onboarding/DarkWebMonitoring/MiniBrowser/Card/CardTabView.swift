import SwiftUI
import UIDelight

struct CardTabView: View {

    @Environment(\.sizeCategory) var sizeCategory

    var title: String
    var isSelected: Bool = false

    @Binding
    var collapsed: Bool

    var body: some View {
        textView()
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(asset: isSelected ? FiberAsset.mainGreen : FiberAsset.midGreen))
    }

    @ViewBuilder
    private func textView() -> some View {
        if isSelected {
            HStack {
                defaultText
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 10, height: 5, alignment: .center)
                    .foregroundColor(Color.white)
                    .rotationEffect(Angle(degrees: collapsed ? 180 : 0))
            }
        } else {
            defaultText
        }
    }

    private var defaultText: some View {
        Text(title)
            .fontWeight(isSelected ? .semibold : .regular)
            .minimumScaleFactor(1)
            .foregroundColor(Color.white)
            .font(sizeCategory.isAccessibilityCategory ? .system(size: 25) : .footnote) 
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            VStack {
                HStack(spacing: 0) {
                    CardTabView(title: "What should I do ?", isSelected: false, collapsed: .constant(true))
                    CardTabView(title: "Password Generator", isSelected: true, collapsed: .constant(false))
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .previewLayout(.sizeThatFits)
    }
}
