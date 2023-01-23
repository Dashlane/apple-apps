import SwiftUI

struct DetailsNoteField: View {
    
    let title: String
    let value: String
    let copy: (String) -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .foregroundColor(Color(asset: Asset.secondaryHighlight))
                    .font(Typography.caption)
                Text(value)
                    .foregroundColor(Color(asset: Asset.primaryHighlight))
                    .font(Typography.caption2)
            }
            Spacer()
            copyButton.opacity(isHovered ? 1.0 : 0.0)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .onHover(perform: { hovering in
            isHovered = hovering
        })
    }
    
    @ViewBuilder
    var copyButton: some View {
        RowActionButton(enabled: !value.isEmpty,
                        action: { copy(value) },
                        label: Image(asset: Asset.copyInfo))
    }
}

struct DetailsNoteField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailsNoteField(title: "Detail", value: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", copy: { _ in })
        }
        .frame(width: 400)
    }
}
