import Foundation
import SwiftUI

struct ToastOverlay: View {
    @Binding
    var currentContent: ToastContent?

    var body: some View {
        ZStack(alignment: .top) {
            if let currentContent {
                ToastCapsule {
                    currentContent.view

                }
                .compositingGroup()
                .onTapGesture {
                    self.currentContent = nil
                }
                .padding(.horizontal)
                .id(currentContent.date)
                .transition(.asymmetric(insertion: .insertToast,
                                        removal: .removeToast))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .animation(.spring( response: 0.7, dampingFraction: 0.6), value: currentContent?.date)
        .task(id: currentContent?.date) {
            do {
                guard let currentContent else {
                    return
                }
                try await Task.sleep(nanoseconds: 1_500_000_000)
                if currentContent.date == self.currentContent?.date {
                    self.currentContent = nil
                }
            } catch {

            }
        }
    }
}

fileprivate extension AnyTransition {
    static var insertToast: AnyTransition {
        .move(edge: .top).combined(with: .opacity)
    }

    static var removeToast: AnyTransition {
        .modifier(active:  DisappearModifier(blurRadius: 13, opacity: 0, scale: 0.5),
                  identity: DisappearModifier(blurRadius: 0, opacity: 1, scale: 1))
    }
}

fileprivate struct DisappearModifier: ViewModifier {
    let blurRadius: Double
    let opacity: Double
    let scale: Double

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(x: scale, y: scale)
            .blur(radius: blurRadius)
    }
}

struct ToastOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ToastModifier_Previews.previews
    }
}

