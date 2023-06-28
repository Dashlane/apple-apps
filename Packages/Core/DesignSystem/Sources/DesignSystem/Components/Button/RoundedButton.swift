import SwiftUI

public struct RoundedButton<Content: View>: View {
    @Environment(\.controlSize)
    private var controlSize

    @Environment(\.roundedButtonDisplayProgressIndicator)
    private var displayProgressIndicator

    @ScaledMetric
    private var contentScale = 100 

    let content: Content
    let action: @MainActor () -> Void

    init(action: @escaping @MainActor () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                contentView
                if displayProgressIndicator {
                    progressView
                        .transition(.scale(scale: 0.2).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: displayProgressIndicator)
            .frame(minHeight: controlSize.minimumContentHeight(forContentScale: effectiveContentScale))
            .fixedSize(horizontal: isIconOnlyConfiguration, vertical: false)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(RoundedButtonStyle())
    }

    private var contentView: some View {
        content
            .opacity(displayProgressIndicator ? 0 : 1)
            .scaleEffect(displayProgressIndicator ? 0.7 : 1)
    }

    private var progressView: some View {
        ProgressView()
            .tint(.accentColor)
            .progressViewStyle(.automatic)
    }

    private var isIconOnlyConfiguration: Bool {
        return Content.self == RoundedButtonIconContentView.self
    }

    private var effectiveContentScale: Double {
        contentScale / 100
    }
}

private extension ControlSize {
    func minimumContentHeight(forContentScale contentScale: Double) -> Double {
        switch self {
        case .mini, .small:
            return 40 * contentScale
        case .regular, .large:
            fallthrough
        @unknown default:
            return 48 * contentScale
        }
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationButtonPreview()
        StylesButtonPreview()
    }
}
