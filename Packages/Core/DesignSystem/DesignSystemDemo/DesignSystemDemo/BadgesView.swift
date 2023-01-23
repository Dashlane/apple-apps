import SwiftUI
import DesignSystem

struct BadgesView: View {
    enum ViewConfiguration: String, CaseIterable {
        case lightColorScheme
        case darkColorScheme
        case smallestTextSize
        case largestTextSize
    }

    var viewConfiguration: ViewConfiguration? {
        guard let configuration = ProcessInfo.processInfo.environment["badgesConfiguration"]
        else { return nil }
        return ViewConfiguration(rawValue: configuration)
    }

    var body: some View {
        switch viewConfiguration {
        case .lightColorScheme:
            contentView
        case .darkColorScheme:
            contentView
                .preferredColorScheme(.dark)
        case .smallestTextSize:
            contentView
                .dynamicTypeSize(.xSmall)
        case .largestTextSize:
            contentView
                .dynamicTypeSize(.accessibility5)
        case .none:
            EmptyView()
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            ForEach(Array(Mood.allCases.enumerated()), id: \.offset) { y, mood in
                VStack(spacing: 0) {
                    ForEach(Array(Intensity.allCases.enumerated()), id: \.offset) { x, intensity in
                        HStack(spacing: 0) {
                            Badge("Label \((y * numberOfAppearancePerMood) + (x * 3))")
                            Badge("Label \((y * numberOfAppearancePerMood + 1) + (x * 3))", icon: .ds.lock.outlined)
                            Badge("Label \((y * numberOfAppearancePerMood + 2) + (x * 3))", icon: .ds.lock.outlined)
                                .iconAlignment(.trailing)
                        }
                        .style(mood: mood, intensity: intensity)
                    }
                }
            }
        }
    }

    private var numberOfAppearancePerMood: Int {
        Intensity.allCases.count * 3
    }
}

struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView()
            .ignoresSafeArea()
            .previewDevice("iPhone 14 Pro")
    }
}
