import SwiftUI

private struct BubbleErrorMessage: View {
    @Binding var text: String?
    @AccessibilityFocusState private var focus

    var body: some View {
        ZStack {
            if let text = text {
                Text(text)
                    .fiberAccessibilityFocus($focus)
                    .font(.body)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .arrowBackground()
                    .onTapGesture {
                        self.text = nil
                    }
                    .transition(AnyTransition.bubbleAnimation)
            }
        }
        .animation(.spring(), value: (text != nil))
        .onChange(of: text) { text in
            guard let text, !text.isEmpty else { return }
            
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focus = true
            }
        }
    }
}

private extension AnyTransition {
    static var bubbleAnimation: AnyTransition {
        return AnyTransition
            .modifier(active: BubbleScaleModifier(scale: 0), identity: BubbleScaleModifier(scale: 1))
            .combined(with: .opacity)
    }
}

private struct BubbleScaleModifier: ViewModifier {
    let scale: CGFloat

    func body(content: Content) -> some View {
        content.scaleEffect(scale, anchor: .bottomLeading)
    }
}

private struct BubbleBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(BubbleShape().fill(Color.white))
            .shadow(color: Color.black.opacity(0.1), radius: 10)
            .padding(.bottom, BubbleShape.arrowSize)
            .padding(.horizontal, 20)
    }
}

private extension View {
    func arrowBackground() -> some View {
        self.modifier(BubbleBackgroundModifier())
    }
}

public extension View {
        func bubbleErrorMessage(text: Binding<String?>) -> some View {
        return self.overlay(
            BubbleErrorMessage(text: text)
                .alignmentGuide(.top, to: .bottom), alignment: .top)
    }
}

struct BubbleMessagePreviews: PreviewProvider {
    static var previews: some View {
        Group {
            BubbleErrorMessage(text: .constant("The email is not valid."))
            BubbleErrorMessage(text: .constant("The email is not validThe email is not valid.The email is not valid.The email is not valid.."))
        }
        .padding()
        .background(Color.secondary)
        .previewLayout(.sizeThatFits)
    }
}
