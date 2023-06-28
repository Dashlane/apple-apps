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
            case .outline: return Color(asset: FiberAsset.neutralText)
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
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                HStack(spacing: 0) {
                    ForEach(options.indices, id: \.self) { index in
                        segment(options[index], currentIndex: index)
                            .padding(.bottom, 12)
                    }
                }

                let height: CGFloat = 2
                Rectangle()
                    .frame(width: geometry.size.width / CGFloat(options.count), height: height)
                    .foregroundColor(Color(asset: FiberAsset.midGreen))
                    .position(x: positionOffset(forIndicatorWidth: geometry.size.width / CGFloat(options.count)), y: geometry.size.height - height/2)
            }
            .animation(.easeInOut, value: selectedIndex)
        }.frame(height: 50)
    }

    @ViewBuilder
    private func segment(_ value: CustomSegment, currentIndex: Int) -> some View {
        Button(action: {
            selectedIndex = options.firstIndex(of: value) ?? 0
        }, label: {
            HStack {
                Spacer()
                Text(value.title)
                    .font(.system(.body))
                    .foregroundColor(selectedIndex == currentIndex ? .ds.text.brand.standard : Color(UIColor.label))
                value.segmentTag
                Spacer()
            }
        })
                .accessibilityAddTraits(selectedIndex == currentIndex ? [.isSelected] : [])
        .accessibilityLabel("\(value.title) \(value.segmentTag.tag)")
    }
}

struct CustomSegmentedControl_Previews: PreviewProvider {
    static var previews: some View {
        CustomSegmentedControl(selectedIndex: .constant(0),
                               options: [
                                StaticSegments.pendingSegment,
                                StaticSegments.solvedSegment
                               ])
    }
}

struct StaticSegments {
    static let pendingSegment = CustomSegment(title: "Pending",
                                              segmentTag: SegmentTag(tag: 0, type: .full))
    static let solvedSegment = CustomSegment(title: "Solved",
                                             segmentTag: SegmentTag(tag: 1, type: .outline))
}
