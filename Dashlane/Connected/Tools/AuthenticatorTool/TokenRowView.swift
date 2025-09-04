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
  let expandCollapseAction: () -> Void

  init(
    model: @autoclosure @escaping () -> TokenRowViewModel,
    rowMode: TokenRowMode,
    expandCollapseAction: @escaping () -> Void,
    performTrailingAction: @escaping (TokenRowAction) -> Void
  ) {
    self._model = .init(wrappedValue: model())
    self.rowMode = rowMode
    self.expandCollapseAction = expandCollapseAction
    self.performTrailingAction = performTrailingAction
  }

  let columns = [
    GridItem(.fixed(56), spacing: 16, alignment: .center),
    GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16, alignment: .leading),
    GridItem(.fixed(24)),
  ]

  var showCode: Bool {
    return rowMode == .expanded || rowMode == .edition
  }

  var body: some View {
    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
      icon
      VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 8) {
          Text(model.title)
            .font(.headline)
            .foregroundStyle(Color.ds.text.neutral.catchy)
          if model.isDashlaneToken {
            Text(model.dashlaneTokenCaption.uppercased())
              .foregroundStyle(Color.ds.text.brand.standard)
              .font(.caption2)
              .padding(4)
              .background(.ds.container.expressive.brand.quiet.idle)
              .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
          }
        }
        if !model.subtitle.isEmpty {
          Text(model.subtitle)
            .font(.caption)
            .foregroundStyle(Color.ds.text.neutral.quiet)
            .fiberAccessibilityHidden(rowMode == .view)
        }
      }

      Button(
        action: expandCollapseAction,
        label: {
          Image(systemName: "chevron.down")
            .rotationEffect(rowMode == .expanded ? .degrees(-180) : .degrees(0))
            .foregroundStyle(Color.ds.text.neutral.standard)
            .opacity(rowMode == .edition ? 0 : 1)
            .fiberAccessibilityHidden(rowMode == .edition)
        }
      )
      .fiberAccessibilityLabel(
        Text(
          rowMode == .expanded
            ? L10n.Localizable.accessibilityCollapse : L10n.Localizable.accessibilityExpand))

      if showCode {
        code
      }
    }
    .padding([.leading, .top], 16)
    .padding(.bottom, 16)
    .padding(.trailing, 20)
    .fiberAccessibilityElement(children: .contain)
    .fiberAccessibilityLabel(Text("\(model.title) \(rowMode.accessibilityDescription)"))
  }

  @ViewBuilder
  private var icon: some View {
    DomainIconView(model: model.makeDomainIconViewModel())
      .fiberAccessibilityHidden(true)
  }

  @ViewBuilder
  var code: some View {
    GeneratedOTPCodeRowView(
      model: model.makeGeneratedOTPCodeRowViewModel(),
      isEditing: rowMode == .edition,
      performAction: performTrailingBasicAction
    )
    .accessibilityElement(children: .combine)
  }

  private func performTrailingBasicAction(_ action: BasicTokenRowAction) {
    switch action {
    case .copy(let code, let token):
      performTrailingAction(.copy(code, token: token))
    case .delete(let otp):
      performTrailingAction(.delete(otp))
    }
  }
}

extension TokenRowMode {
  fileprivate var accessibilityDescription: String {
    switch self {
    case .edition:
      return ""
    case .expanded:
      return L10n.Localizable.accessibilityExpanded
    case .view:
      return L10n.Localizable.accessibilityCollapsed
    }
  }
}

struct TokenRowView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      Group {
        TokenRowView(
          model: .mock(), rowMode: .view, expandCollapseAction: {}, performTrailingAction: { _ in })
        TokenRowView(
          model: .mock(), rowMode: .expanded, expandCollapseAction: {},
          performTrailingAction: { _ in })
        TokenRowView(
          model: .mock(), rowMode: .edition, expandCollapseAction: {},
          performTrailingAction: { _ in })

      }.previewLayout(.sizeThatFits)
    }
  }
}
