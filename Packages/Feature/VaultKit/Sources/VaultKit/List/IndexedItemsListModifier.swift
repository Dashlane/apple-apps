import Combine
import CoreHaptics
import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI

struct IndexedItemsListModifier {
    @ViewBuilder
    func body<RowView: View>(content: ItemsList<RowView>, shouldHideIndexes: Bool, _ accessibilityPriority: Double) -> some View {
        ScrollViewReader { reader in
            content
                .overlay(alignment: .trailing) {
                    if content.sections.count > 1 && !shouldHideIndexes {
                        SectionIndexes(sectionIndexes: content.sections.sortedListIndexes()) { sectionIndex in
                            DispatchQueue.main.async {
                                reader.scrollTo(sectionIndex, anchor: .top)
                            }

                        }
                        .accessibilitySortPriority(accessibilityPriority)
                    }
                }
                .accessibilityElement(children: .contain)
        }
    }
}

public extension ItemsList {
            @ViewBuilder
    func indexed(shouldHideIndexes: Bool = false, accessibilityPriority: Double = 0) -> some View {
        if Device.isMac {
            self
        } else {
            IndexedItemsListModifier()
                .body(content: self, shouldHideIndexes: shouldHideIndexes, accessibilityPriority)
        }
    }
}

private extension Array where Element == DataSection {
    func sortedListIndexes() -> [Character] {
        return Set(self.map { $0.listIndex })
            .sorted { $0 < $1 }
    }
}

private struct SectionIndexes: View {
    let sectionIndexes: [Character]
    let select: (Character) -> Void

    private let didSelect = PassthroughSubject<Character, Never>()
    private let hapticGenerator = HapticGenerator()
    private let desiredIndexSize: CGFloat = 16
    private let width: CGFloat = 16

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(sectionIndexes, id: \.self) { index in
                Text(String(index))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.7)
                    .frame(height: self.desiredIndexSize, alignment: .center)
                    .foregroundColor(.ds.text.brand.quiet)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(L10n.Core.vaultItemListSectionIndex(String(index).lowercased()))
            }
        }
        .frame(width: width)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged(updateSelection))
        .onReceive(didSelect.removeDuplicates(), perform: performSelect)
    }

    private func updateSelection(forEvent event: DragGesture.Value) {
        let rawIndex = Int(event.location.y / self.desiredIndexSize)
        let index = min(max(0, rawIndex), sectionIndexes.endIndex - 1)

        didSelect.send(sectionIndexes[index])
    }

    private func performSelect(_ selection: Character) {
        select(selection)
        hapticGenerator?.perform()
    }
}

private struct HapticGenerator {
    let engine: CHHapticEngine
    let player: CHHapticPatternPlayer
    init?() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = try? CHHapticEngine() else {
            return nil
        }

        do {
            let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity,
                                                            value: 0.57)

            let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness,
                                                            value: 0.5)

            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            player = try engine.makePlayer(with: pattern)

            self.engine = engine
        } catch {
            return nil
        }

    }

    func perform() {
        do {
            try engine.start()
            try player.start(atTime: 0)
        } catch {

        }
    }
}
