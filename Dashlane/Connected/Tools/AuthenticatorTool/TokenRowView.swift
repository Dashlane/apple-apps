import SwiftUI
import CoreSync
import Combine
import UIDelight
import AuthenticatorKit
import VaultKit

enum TokenRowMode {
    case view
    case expanded
    case edition
    case preview
}

enum TokenRowAction {
    case copy(_ code: String, token: OTPInfo)
    case delete(OTPInfo)
}

struct TokenRowView: View {

    @StateObject
    var model: TokenRowViewModel

    let rowMode: TokenRowMode

    let performTrailingAction: (TokenRowAction) -> Void

    init(model: @autoclosure @escaping () -> TokenRowViewModel,
         rowMode: TokenRowMode,
         performTrailingAction: @escaping (TokenRowAction) -> Void) {
        self._model = .init(wrappedValue: model())
        self.rowMode = rowMode
        self.performTrailingAction = performTrailingAction
    }

    let columns = [
        GridItem(.fixed(56), spacing: 16, alignment: .center),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16, alignment: .leading),
        GridItem(.fixed(24))
    ]

    var showCode: Bool {
        return rowMode == .expanded || rowMode == .edition || rowMode == .preview
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                icon
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(model.title)
                            .font(.headline)
                            .foregroundColor(.ds.text.neutral.catchy)
                        if model.isDashlaneToken {
                            Text(model.dashlaneTokenCaption.uppercased())
                                .foregroundColor(.ds.text.brand.standard)
                                .font(.caption2)
                                .padding(4)
                                .background(.ds.container.expressive.brand.quiet.idle)
                                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                        }
                    }
                    if !model.subtitle.isEmpty {
                        Text(model.subtitle)
                            .font(.caption)
                            .foregroundColor(.ds.text.neutral.quiet)
                    }
                }

            Image(systemName: "chevron.down")
                .rotationEffect(rowMode == .expanded ? .degrees(-180) : .degrees(0))
                .foregroundColor(.ds.text.neutral.standard)
                .opacity(rowMode == .edition || rowMode == .preview ? 0 : 1)

            if showCode {
                code
            }
        }
        .padding([.leading, .top], 16)
        .padding(.bottom, 16)
        .padding(.trailing, 20)
    }

    @ViewBuilder
    private var icon: some View {
        DomainIconView(animate: false,
                       model: model.makeDomainIconViewModel(),
                       placeholderTitle: model.token.configuration.issuerOrTitle)
    }

    @ViewBuilder
    var code: some View {
                  GeneratedOTPCodeRowView(model: model.makeGeneratedOTPCodeRowViewModel(),
                                isEditing: rowMode == .edition,
                                performAction: performTrailingAction)
    }
}

struct TokenRowView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            Group {
                TokenRowView(model: .mock(), rowMode: .view, performTrailingAction: { _ in })
                TokenRowView(model: .mock(), rowMode: .expanded, performTrailingAction: { _ in })
                TokenRowView(model: .mock(), rowMode: .edition, performTrailingAction: { _ in })

            }.previewLayout(.sizeThatFits)
        }
    }
}
