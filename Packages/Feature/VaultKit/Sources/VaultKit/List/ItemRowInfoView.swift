import SwiftUI
import Combine
import CorePersonalData
import UIDelight

private let displayDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .named
    return formatter
}()

public struct ItemRowInfoView: View {

    public enum InfoType {
        case title
        case subtitle
    }

    let item: VaultItem
    let highlightedString: String?
    let type: InfoType

    public init(
        item: VaultItem,
        highlightedString: String?,
        type: InfoType
    ) {
        self.item = item
        self.highlightedString = highlightedString
        self.type = type
    }

    public var body: some View {
        switch type {
        case .title:
            title
                .lineLimit(1)
                .id(highlightedString)
        case .subtitle:
            HStack {
                if let subtitleImage = item.subtitleImage {
                    subtitleImage
                        .resizable()
                        .frame(width: 21, height: 14)
                }
                subtitle
                    .id(highlightedString)
            }
        }
    }

    @ViewBuilder
    private var title: some View {
        if let highlightedString = highlightedString, !highlightedString.isEmpty {
            PartlyModifiedText(text: item.localizedTitle, toBeModified: highlightedString) { text in
                text
                    .bold()
                    .foregroundColor(.ds.text.neutral.catchy)
            }
            .fiberAccessibilityLabel(Text(item.localizedTitle))
        } else {
            Text(item.localizedTitle)
                .font(.body.weight(.medium))
        }
    }

    @ViewBuilder
    private var subtitle: some View {
        itemEmphasizedTextSubtitle
            .lineLimit(1)
    }

    @ViewBuilder
    private var itemEmphasizedTextSubtitle: some View {
        if let highlightedString = highlightedString,
           let result = item.matchCriteria(highlightedString),
           case let .secondaryInfo(value) = result.location {
            PartlyModifiedText(
                text: value,
                toBeModified: highlightedString,
                truncateString: true,
                textModifier: {
                    $0.foregroundColor(.ds.text.neutral.quiet)
                },
                toBeModifiedModifier: { text in
                    text
                        .bold()
                        .foregroundColor(.ds.text.neutral.catchy)
                }
            )
        } else {
            Text(item.localizedSubtitle)
                .font(item.subtitleFont ?? .footnote)
                .foregroundColor(.ds.text.neutral.quiet)
        }
    }

}

struct ItemRowInfoView_Previews: PreviewProvider {
    static var credential: Credential {
        var credential = Credential()
        credential.login = "toto la menace"
        credential.title = "My password"
        return credential
    }

    static var previews: some View {
        ItemRowInfoView(item: Credential(), highlightedString: "la menace", type: .title)
    }
}
