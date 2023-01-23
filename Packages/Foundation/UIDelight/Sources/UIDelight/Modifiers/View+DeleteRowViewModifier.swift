import SwiftUI

private struct DeleteRowViewModifier: ViewModifier {
    
    let deleteImage: Image
    let action: () -> Void
    let isInProgress: (Bool) -> Void
    
        @State private var offset: CGSize = .zero
        @State private var initialOffset: CGSize = .zero
    
    @State private var willDeleteIfReleased = false
  
    @GestureState private var dragGestureActive: Bool = false
    
        let automaticDeletionDistance = CGFloat(200)
        let tappableDeletionWidth = CGFloat(100)
    
    func body(content: Content) -> some View {
        ZStack {
            content
                                    if offset.width < 0 {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        offset = .zero
                        initialOffset = .zero
                    }
            }
        }
        .background(
            GeometryReader { geometry in
                ZStack {
                    if offset.width < 0 {
                        Rectangle()
                            .foregroundColor(.red)
                        deleteImage
                            .foregroundColor(.white)
                            .font(.title2.bold())
                            .layoutPriority(-1)
                            .onAppear() {
                                isInProgress(true)
                            }
                            .onDisappear() {
                                isInProgress(false)
                            }
                    }
                }
                .accessibilityElement()
                .accessibilityIdentifier("Delete")
                .accessibilityAddTraits(.isButton)
                .frame(width: -offset.width)
                .offset(x: geometry.size.width)
                .onTapGesture {
                    guard initialOffset.width < 0 || offset.width < 0 else { return }
                    delete()
                }
                .onChange(of: dragGestureActive) { isActive in
                    guard !isActive else { return }
                    dragGestureEnded()
                }
            }
        )
        .offset(x: offset.width, y: 0)
        .gesture (dragGesture())
        .animation(.default, value: offset)
    }
    
    private func dragGesture() -> some Gesture {
        DragGesture()
                            .updating($dragGestureActive) { value, state, transaction in
                state = true
            }
            .onChanged { gesture in
                                if gesture.translation.width + initialOffset.width <= 0 {
                    self.offset.width = gesture.translation.width + initialOffset.width
                }
                if self.offset.width < -automaticDeletionDistance && !willDeleteIfReleased {
                                                            hapticFeedback()
                    willDeleteIfReleased = true
                } else if offset.width > -automaticDeletionDistance && willDeleteIfReleased {
                                                            hapticFeedback()
                    willDeleteIfReleased = false
                }
            }
    }
    
    private func dragGestureEnded() {
                if offset.width < -automaticDeletionDistance {
            delete()
        }
                        else if offset.width < -(tappableDeletionWidth / 2) {
            offset.width = -tappableDeletionWidth
            initialOffset.width = -tappableDeletionWidth
        }
                        else {
            offset = .zero
            initialOffset = .zero
        }
    }
    
    private func delete() {
        action()
                offset = .zero
        initialOffset = .zero
    }
    
    private func hapticFeedback() {
        UserFeedbackGenerator.makeImpactGenerator()?.impactOccurred()
    }
}

public extension View {
    
        @ViewBuilder
    func deletableRow(isEnabled: Bool = true,
                      deleteImage: Image = Image(systemName: "trash"),
                      isInProgress: @escaping (Bool) -> Void,
                      perform action: @escaping () -> Void) -> some View {
        if isEnabled {
            self.modifier(DeleteRowViewModifier(deleteImage: deleteImage,
                                                action: action,
                                               isInProgress: isInProgress))
        } else {
            self
        }
    }
    
}

struct DeleteRowViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("1")
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .deletableRow(isInProgress: { _ in }) {
                    print("Delete")
                }
        }
    }
}
