import SwiftUI

struct DetailsBasicField: View {
    
    let title: String
    let value: String
    var placeholder: String = ""
    let copy: (String) -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .foregroundColor(Color(asset: Asset.secondaryHighlight))
                    .font(Typography.caption)
                
                if !value.isEmpty {
                    Text(value)
                        .foregroundColor(Color(asset: Asset.primaryHighlight))
                        .font(Typography.body)
                } else {
                    Text(placeholder)
                        .foregroundColor(Color(asset: Asset.secondaryHighlight))
                        .font(Typography.body)
                }
            }
            .lineLimit(1)
            Spacer()
            if isHovered {
                copyButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct DetailsBasicField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailsBasicField(title: "Detail", value: "A value", placeholder: "Placeholder", copy: { _ in })
            DetailsBasicField(title: "Detail", value: "", placeholder: "Placeholder", copy: { _ in })
            
            DetailsBasicField(title: "Detail", value: "A value", placeholder: "Placeholder", copy: { _ in })
        }
        .frame(width: 400, height: 80)
    }
}
