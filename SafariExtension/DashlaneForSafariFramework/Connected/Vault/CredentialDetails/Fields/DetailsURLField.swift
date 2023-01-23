import SwiftUI
import CorePersonalData

struct DetailsURLField: View {
    
    let title: String
    let value: PersonalDataURL
    let openWebsite: (PersonalDataURL) -> Void
    
    var canOpen: Bool {
        value.openableURL != nil
    }
    
    @State private var isHovered: Bool = false
 
    @ViewBuilder
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .foregroundColor(Color(asset: Asset.secondaryHighlight))
                    .font(Typography.caption)
                    url
                        .font(Typography.body)
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
    
    var url: some View {
        (Text(value.displayedScheme) +
            Text(value.displayDomain)
            .foregroundColor(Color(asset: Asset.accentColor)))
    }
    
    @ViewBuilder
    var copyButton: some View {
        RowActionButton(enabled: value.openableURL != nil,
                        action: {
                            openWebsite(value)
                        },
                        label: Image(asset: Asset.goToWebsite))
    }
}

struct DetailsURLField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailsURLField(title: "Detail", value: PersonalDataURL(rawValue: "_"), openWebsite: { _ in })
        }
        .frame(width: 400, height: 80)
    }
}
