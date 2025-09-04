import Combine
import CoreHaptics
import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI

extension ItemsList {
  @ViewBuilder
  public func indexed(shouldHideIndexes: Bool = false, accessibilityPriority: Double = 0)
    -> some View
  {
    if Device.is(.mac) {
      self
    } else {
      self.modifier(
        IndexedItemsListModifier(
          sections: sections,
          shouldHideIndexes: shouldHideIndexes,
          accessibilityPriority: accessibilityPriority))
    }
  }
}

private struct IndexedItemsListModifier: ViewModifier {
  let sections: [DataSection]
  let shouldHideIndexes: Bool
  let accessibilityPriority: Double

  func body(content: Content) -> some View {
    let shouldDisplayIndexes = sections.count > 1 && !shouldHideIndexes
    ScrollViewReader { reader in
      content
        .overlay(alignment: .trailing) {
          if shouldDisplayIndexes {
            SectionIndexes(sectionIndexes: sections.listIndexes) { sectionIndex in
              DispatchQueue.main.async {
                reader.scrollTo(sectionIndex, anchor: .top)
              }

            }
            .accessibilitySortPriority(accessibilityPriority)
          }
        }
        .accessibilityElement(children: .contain)
        .contentMargins(.trailing, shouldDisplayIndexes ? 16 : nil)
    }
  }
}

extension Array where Element == DataSection {
  fileprivate var listIndexes: some RandomAccessCollection<Character> {
    return lazy.filter {
      !$0.isSuggestedItems
    }.map(\.listIndex)
  }
}

private struct SectionIndexes<C: RandomAccessCollection<Character>>: View {
  let sectionIndexes: C
  let select: (Character) -> Void

  @State private var didSelect = PassthroughSubject<Character, Never>()
  @State private var hapticGenerator = HapticGenerator()
  private let desiredIndexSize: CGFloat = 16
  private let width: CGFloat = 16

  var body: some View {
    VStack(alignment: .trailing, spacing: 0) {
      ForEach(sectionIndexes, id: \.self) { index in
        Text(String(index))
          .font(.system(size: 11, weight: .bold, design: .monospaced))
          .minimumScaleFactor(0.7)
          .frame(height: self.desiredIndexSize, alignment: .center)
          .foregroundStyle(Color.ds.text.brand.quiet)
          .accessibilityAddTraits(.isButton)
          .accessibilityLabel(CoreL10n.vaultItemListSectionIndex(String(index).lowercased()))
      }
    }
    .frame(width: width)
    .contentShape(Rectangle())
    .gesture(
      DragGesture(minimumDistance: 0, coordinateSpace: .local)
        .onChanged(updateSelection)
    )
    .onReceive(didSelect.removeDuplicates(), perform: performSelect)
  }

  private func updateSelection(forEvent event: DragGesture.Value) {
    let rawIndex = Int(event.location.y / self.desiredIndexSize)
    let index = min(max(0, rawIndex), sectionIndexes.count - 1)

    didSelect.send(sectionIndexes[sectionIndexes.index(sectionIndexes.startIndex, offsetBy: index)])
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
      let engine = try? CHHapticEngine()
    else {
      return nil
    }

    do {
      let intensityParameter = CHHapticEventParameter(
        parameterID: .hapticIntensity,
        value: 0.57)

      let sharpnessParameter = CHHapticEventParameter(
        parameterID: .hapticSharpness,
        value: 0.5)

      let event = CHHapticEvent(
        eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter],
        relativeTime: 0)
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
