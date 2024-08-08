import DesignSystem
import SwiftUI

struct SegmentTag: View {

  enum TagType {
    case outline
    case full
  }

  var tag: Int
  var type: TagType

  @ViewBuilder
  var body: some View {
    background
      .frame(width: 20)
      .overlay(textView(tag))
  }

  @ViewBuilder
  private var background: some View {
    switch type {
    case .outline:
      Circle()
        .stroke(Color(UIColor.lightGray), lineWidth: 1.0)
    case .full:
      Circle()
        .foregroundColor(.ds.text.danger.quiet)
    }
  }

  private func textView(_ tag: Int) -> some View {
    Text(String(tag))
      .font(.caption2)
      .foregroundColor(textColor)
  }

  private var textColor: Color {
    switch type {
    case .outline: return .ds.text.neutral.quiet
    case .full: return .white
    }
  }
}

struct CustomSegment: Hashable {
  var title: String
  var segmentTag: SegmentTag

  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
  }

  static func == (lhs: CustomSegment, rhs: CustomSegment) -> Bool {
    return lhs.title == rhs.title && lhs.segmentTag.tag == rhs.segmentTag.tag
  }
}

struct CustomSegmentedControl: View {

  @Binding var selectedIndex: Int

  var options: [CustomSegment]

  private func positionOffset(forIndicatorWidth indicatorWidth: CGFloat) -> CGFloat {
    return CGFloat(selectedIndex) * indicatorWidth + indicatorWidth / 2.0
  }

  var body: some View {
    HStack(spacing: 0) {
      ForEach(options.indices, id: \.self) { index in
        segment(options[index], currentIndex: index)
      }
    }
    .padding(.bottom, 12)
    .overlay {
      SelectionMarkerLayout(selectedIndex: selectedIndex, count: options.count) {
        Rectangle()
          .foregroundColor(.ds.text.brand.standard)
          .frame(height: 2)
      }
    }
    .animation(.spring(), value: selectedIndex)
  }

  @ViewBuilder
  private func segment(_ value: CustomSegment, currentIndex: Int) -> some View {
    let isSelected = selectedIndex == currentIndex
    Button(
      action: {
        selectedIndex = options.firstIndex(of: value) ?? 0
      },
      label: {
        HStack {
          Spacer()
          Text(value.title)
            .font(.system(.body))
            .foregroundColor(isSelected ? .ds.text.brand.standard : Color(UIColor.label))
          value.segmentTag
          Spacer()
        }
      }
    )
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    .accessibilityLabel("\(value.title) \(value.segmentTag.tag)")
  }
}

private struct SelectionMarkerLayout: Layout {
  let selectedIndex: Int
  let count: Int

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    return proposal.replacingUnspecifiedDimensions()
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    let position = bounds.minX + bounds.width * Double(selectedIndex) / Double(count)
    let size = bounds.width / Double(count)

    subviews[0].place(
      at: .init(x: position, y: bounds.maxY), anchor: .bottomLeading,
      proposal: .init(width: size, height: 2))
  }
}

struct CustomSegmentedControl_Previews: PreviewProvider {
  static let pendingSegment = CustomSegment(
    title: "Pending",
    segmentTag: SegmentTag(tag: 0, type: .full))
  static let solvedSegment = CustomSegment(
    title: "Solved",
    segmentTag: SegmentTag(tag: 1, type: .outline))

  struct TestView: View {
    @State
    var selectedIndex: Int = 0

    var body: some View {
      CustomSegmentedControl(
        selectedIndex: $selectedIndex,
        options: [
          pendingSegment,
          solvedSegment,
        ])
    }
  }

  static var previews: some View {
    TestView()
  }
}
