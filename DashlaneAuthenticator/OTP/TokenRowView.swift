import AuthenticatorKit
import Combine
import CoreSync
import IconLibrary
import SwiftUI
import UIDelight
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
  case didDelete(OTPInfo)
  case update(OTPInfo)
  case detail(OTPInfo)
}

struct TokenRowView: View {

  let model: TokenRowViewModel
  let rowMode: TokenRowMode
  let performTrailingAction: (TokenRowAction) -> Void

  var columns: [GridItem] {
    if rowMode == .edition {
      return [
        GridItem(.fixed(56), spacing: 16, alignment: .center),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16, alignment: .leading),
        GridItem(.fixed(24)),
        GridItem(.fixed(24)),
      ]
    }
    return [
      GridItem(.fixed(56), spacing: 16, alignment: .center),
      GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16, alignment: .leading),
      GridItem(.fixed(24)),
    ]
  }

  var showCode: Bool {
    return rowMode == .expanded || rowMode == .preview
  }

  var body: some View {
    if rowMode != .edition && rowMode != .preview {
      mainView
        .contentShape(Rectangle())
        .contextMenu {
          Button {
            performTrailingAction(.detail(model.token))
          } label: {
            Text(L10n.Localizable.buttonEdit)
            Image.ds.action.edit.outlined
          }
          Button(
            action: {
              var token = model.token
              token.isFavorite.toggle()
              Task.delayed(by: 0.5) { @MainActor in
                performTrailingAction(.update(token))
              }
            },
            label: {
              Text(
                model.token.isFavorite
                  ? L10n.Localizable.menuRemoveFavorite : L10n.Localizable.menuAddFavorite)
              Image(systemName: "star")
                .foregroundColor(.ds.text.neutral.standard)
            })
        }
    } else {
      mainView
    }
  }

  @ViewBuilder
  var mainView: some View {
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
      trailingActions
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
    DomainIconView(
      animate: false,
      model: model.makeDomainIconViewModel(),
      placeholderTitle: model.token.configuration.issuerOrTitle)
  }

  @ViewBuilder
  var code: some View {
    GeneratedOTPCodeRowView(
      model: model.makeGeneratedOTPCodeRowViewModel(),
      isEditing: rowMode == .edition,
      performAction: performTrailingBasicAction)
  }

  private func performTrailingBasicAction(_ action: BasicTokenRowAction) {
    switch action {
    case .copy(let code, let token):
      performTrailingAction(.copy(code, token: token))
    case .delete(let otp):
      performTrailingAction(.delete(otp))
    }
  }

  @ViewBuilder
  var trailingActions: some View {
    if rowMode == .edition {
      Button(
        action: {
          performTrailingAction(.detail(model.token))
        },
        label: {
          Image.ds.action.edit.outlined
            .foregroundColor(.ds.text.neutral.standard)
        })

      Button(
        action: {
          var token = model.token
          token.isFavorite.toggle()
          performTrailingAction(.update(token))
        },
        label: {
          Image(systemName: model.token.isFavorite ? "star.fill" : "star")
            .foregroundColor(.ds.text.neutral.standard)
        })
    }

    if rowMode != .edition {
      Image(systemName: "chevron.down")
        .rotationEffect(rowMode == .expanded ? .degrees(-180) : .degrees(0))
        .foregroundColor(.ds.text.neutral.standard)
        .opacity(rowMode == .preview ? 0 : 1)
    }
  }
}

struct TokenRowView_Preview: PreviewProvider {
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
