import SwiftUI
import Combine

struct DetailsSecureField: View {
    let title: String
    
    let value: String
    var placeholder: String = ""
    var enabled = true
    
    var formatter: Formatter?
    var obfuscatingFormatter: Formatter = .obfuscatedCode

    var effectiveFormatter: Formatter? {
        return shouldReveal ? formatter : obfuscatingFormatter
    }
    
    @State var shouldReveal = false
    
    let copy: (String) -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .foregroundColor(Color(asset: Asset.secondaryHighlight))
                    .font(Typography.caption)
                field
            }
            Spacer()
            if isHovered {
                actionButtons
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onHover(perform: { hovering in
            isHovered = hovering
        })
    }
    
    @ViewBuilder
    var field: some View {
        if !value.isEmpty {
            Group {
                if shouldReveal {
                    value.passwordColored(text: value)
                } else {
                    Text("\(value as NSString, formatter: effectiveFormatter)")
                }
            }
            .font(Typography.bodyMonospaced)
            .foregroundColor(Color(asset: Asset.primaryHighlight))
            
        } else {
            Text(placeholder)
                .foregroundColor(Color(asset: Asset.secondaryHighlight))
                .font(Typography.body)
        }
    }
    
    @ViewBuilder
    var actionButtons: some View {
        HStack(spacing: 8) {
            revealButton
            copyButton
        }.frame(width: 75)
    }
    
    @ViewBuilder
    var revealButton: some View {
        RowActionButton(enabled: !value.isEmpty && enabled,
                        action: {
                            shouldReveal.toggle()
                        },
                        label: Image(asset: shouldReveal ? Asset.sensitiveHide : Asset.sensitiveReveal))
    }
    
    @ViewBuilder
    var copyButton: some View {
        RowActionButton(enabled: !value.isEmpty && enabled,
                        action: {
                            copy(value)
                        },
                        label: Image(asset: Asset.copyInfo))
    }
}

struct DetailsSecureField_Previews: PreviewProvider {
    static var previews: some View {
        PopoverPreviewScheme(size: .custom(400, 80)) {
            Group {
                DetailsSecureField(title: "Detail", value: "A value", placeholder: "Placeholder", copy: { _ in })
                DetailsSecureField(title: "Detail", value: "", placeholder: "Placeholder", copy: { _ in })
                DetailsSecureField(title: "Detail", value: "A value", placeholder: "Placeholder", shouldReveal: true, copy: { _ in })
            }
        }
    }
}
