import SwiftUI
import UIDelight

struct CardTabHeader: View {
    @Environment(\.sizeCategory) var sizeCategory

    @Binding var selectedIndex: Int

    @Binding
    var collapsed: Bool

    var staticMessage: String?

    var tabElements: [MiniBrowserTabElement]

    var body: some View {
        if let message = staticMessage {
            return staticHeader(message).eraseToAnyView()
        } else {
            return tabs.eraseToAnyView()
        }
    }

    private var tabs: some View {
        HStack(spacing: 0) {
            ForEach(self.tabElements.indices, id: \.self) { index in
                CardTabView(title: self.tabElements[index].title,
                        isSelected: index == self.selectedIndex, collapsed: self.$collapsed)
                    .onTapGesture {
                        if self.selectedIndex == index {
                            withAnimation {
                                self.collapsed.toggle()
                            }
                        } else {
                            self.collapsed = false
                            self.selectedIndex = index
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(4.0, corners: [.topLeft, .topRight])
    }

    private func staticHeader(_ message: String) -> some View {
        ZStack {
            Text(message)
                .fontWeight(.semibold)
                .padding(.vertical, 11)
                .foregroundColor(Color.white)
                .lineLimit(1)
                .font(sizeCategory.isAccessibilityCategory ? .system(size: 25) : .footnote) 
        }
        .frame(maxWidth: .infinity, minHeight: 38, maxHeight: 60)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(asset: FiberAsset.mainGreen))
        .cornerRadius(4.0, corners: [.topLeft, .topRight])
    }
}

struct CardTabHeader_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            VStack {
                CardTabHeader(selectedIndex: .constant(0),
                              collapsed: .constant(false),
                              staticMessage: nil,
                              tabElements: [
                                MiniBrowserTabElement(title: "What should I do ?"),
                                MiniBrowserTabElement(title: "Password Generator")
                              ])
                CardTabHeader(selectedIndex: .constant(1),
                              collapsed: .constant(false),
                              staticMessage: "Email copied",
                              tabElements: [
                                MiniBrowserTabElement(title: "What should I do ?"),
                                MiniBrowserTabElement(title: "Password Generator")
                              ])
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
