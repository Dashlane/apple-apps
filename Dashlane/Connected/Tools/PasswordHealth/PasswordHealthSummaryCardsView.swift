import SwiftUI
import UIComponents

struct PasswordHealthSummaryCardsView: View {

  @ScaledMetric(relativeTo: .body)
  private var cellHeight: CGFloat = 86

  let summary: [PasswordHealthViewModel.SummaryItem]
  let tappedCell: (PasswordHealthKind) -> Void

  var body: some View {
    LazyVGrid(
      columns: [.init(.flexible(), spacing: 16), .init(.flexible())], alignment: .leading,
      spacing: 16
    ) {
      ForEach(summary, id: \.kind) { item in
        cell(for: item)
          .frame(minHeight: cellHeight)
      }
    }
    .padding(.top, 56)
  }

  private func cell(for item: PasswordHealthViewModel.SummaryItem) -> some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 8) {
        Text("\(item.count)")
          .font(DashlaneFont.custom(26, .bold).font)
          .foregroundColor(item.color)
          .padding(.top, 16)

        Text(item.kind.title)
          .font(.footnote)
          .foregroundColor(.ds.text.neutral.quiet)
          .frame(maxHeight: .infinity)
      }
      .padding([.leading, .trailing, .bottom], 16)

      Spacer()
    }
    .frame(maxHeight: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(Color.ds.container.agnostic.neutral.supershy)

    )

    .fiberAccessibilityElement(children: .combine)
    .onTapGesture {
      if item.count > 0 {
        tappedCell(item.kind)
      }
    }
    .accessibilityAddTraits(item.accessibilityTraitToAdd)
  }
}

extension PasswordHealthViewModel.SummaryItem {
  fileprivate var color: Color? {
    return count == 0 ? .ds.text.neutral.quiet : kind.color
  }
}

extension PasswordHealthKind {
  fileprivate var color: Color? {
    switch self {
    case .weak:
      return .ds.text.warning.quiet
    case .reused:
      return .ds.text.warning.quiet
    case .compromised:
      return .ds.text.danger.quiet
    case .total:
      return .ds.text.brand.quiet
    case .excluded:
      return nil
    }
  }
}

struct PasswordHealthSummaryCardsView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordHealthSummaryCardsView(
      summary: PasswordHealthViewModel.mock.summary, tappedCell: { _ in })
  }
}

extension PasswordHealthViewModel.SummaryItem {

  fileprivate var accessibilityTraitToAdd: AccessibilityTraits {
    switch kind {
    case .total: return .isStaticText
    default: return count > 0 ? .isButton : .isStaticText
    }
  }
}
