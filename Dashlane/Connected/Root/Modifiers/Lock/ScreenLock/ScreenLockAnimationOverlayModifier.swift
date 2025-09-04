import SwiftUI

struct ScreenLockAnimationOverlayModifier: ViewModifier {
  @State
  var opacity: Double = 0
  let animationOrchestrator: ScreenLockAnimationOrchestrator

  func body(content: Content) -> some View {
    content
      .opacity(opacity)
      .overlay {
        ZStack {
          if let animationConfiguration = animationOrchestrator.currentAnimation {
            LockAnimationOverlay(animationConfiguration: animationConfiguration)
              .id(animationConfiguration.animation)
          }
        }
      }
      .environment(animationOrchestrator)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .edgesIgnoringSafeArea(.all)
      .onAppear {
        withAnimation {
          opacity = 1
        }
      }
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }
}

private struct LockAnimationOverlay: View {
  @State var isLocked: Bool
  @Environment(ScreenLockAnimationOrchestrator.self) var animationOrchestrator

  let animationConfiguration: ScreenLockAnimationOrchestrator.AnimationConfiguration

  init(animationConfiguration: ScreenLockAnimationOrchestrator.AnimationConfiguration) {
    self.animationConfiguration = animationConfiguration
    self.isLocked = .init(animationConfiguration.animation == .unlock)
  }

  var body: some View {
    animationConfiguration.contentPlaceholder
      .edgesIgnoringSafeArea(.all)
      .lockCover(isPresented: isLocked) {
        animationConfiguration.lockPlaceholder.edgesIgnoringSafeArea(.all)
      }
      .onAppear {
        isLocked.toggle()
      }
      .transaction { transaction in
        transaction.addAnimationCompletion {
          animationOrchestrator.completed()
        }
      }
  }
}
