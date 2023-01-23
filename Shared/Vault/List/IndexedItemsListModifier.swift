import Foundation
import SwiftUI
import CorePersonalData
import CoreHaptics
import Combine
import SwiftTreats
import DashlaneAppKit
import VaultKit
import DesignSystem

struct IndexedItemsListModifier {
    @ViewBuilder
    func body<RowView: View>(content: ItemsList<RowView>, shouldHideIndexes: Bool, _ accessibilityPriority: Double) -> some View {
        ScrollViewReader { reader in
            ZStack(alignment: .trailing) {
                content
                if content.sections.count > 1 && !shouldHideIndexes {
                    SectionIndexes(sectionIndexes: content.sections.sortedListIndexes()) { sectionIndex in
                        reader.scrollTo(sectionIndex, anchor: .top)
                    }
                    .accessibilitySortPriority(accessibilityPriority)
                }
            }
            .accessibilityElement(children: .contain)
        }
    }
}

extension ItemsList {
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

struct IndexedItemsList_Previews: PreviewProvider {

    static var items: [DataSection] {
        PersonalDataMock.Credentials.all.alphabeticallyGrouped()
    }

    static var allCharacters: [DataSection] {
        return "#abcdefghijklmnopqrstuvwxyz".map {
            DataSection(name: String($0), items: [Credential()])
        }
    }

    static func delete(_ item: VaultItem) {

    }

    #if EXTENSION
    static func row(for input: ItemRowViewConfiguration) -> some View {
        return CredentialRowView(model: CredentialRowView_Previews.mockModel) {}
    }
    #else
    static func row(for input: ItemRowViewConfiguration) -> some View {
        VaultItemRow(model: .mock(item: input.vaultItem))
            .padding(.trailing, 10)
    }
    #endif

    static var previews: some View {
        Group {
            ItemsList(sections: items, rowProvider: row)
                .indexed()
            
            TabView {
                NavigationView {
                    ItemsList(sections: items, rowProvider: row)
                        .indexed()
                        .navigationTitle("All Characters")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .vaultItemsListDelete(.init(delete))
    }
}
