import Combine
import SwiftUI
import UIKit

private let loadingAnimationDelay = 1.0
private let animationDuration = 0.3

extension View {
  public func loading(_ isLoading: Bool) -> some View {
    let coordinator = LoadingOverlayWindowCoordinator.shared
    return
      self
      .onChange(of: isLoading) { _, _ in
        if isLoading {
          coordinator.show()
        } else {
          coordinator.dismiss()
        }
      }
      .onDisappear {
        coordinator.dismiss()
      }
  }
}

@MainActor public final class LoadingOverlayWindowCoordinator {
  public static let shared = LoadingOverlayWindowCoordinator()

  private var window: UIWindow?
  fileprivate let dismissPublisher: PassthroughSubject<Void, Never> = .init()

  private var currentLoadingCount: Int = 0

  func show() {
    guard
      let scene = UIApplication.shared.connectedScenes
        .first(where: { $0 is UIWindowScene }) as? UIWindowScene
    else {
      return
    }

    currentLoadingCount += 1

    guard window == nil else {
      return
    }

    let newWindow = UIWindow(windowScene: scene)
    newWindow.windowLevel = .statusBar + 1
    let view = LoadingOverlayContainerView(dismissPublisher: dismissPublisher)
    let hostingController = UIHostingController(rootView: view)
    hostingController.view.backgroundColor = .clear
    newWindow.rootViewController = hostingController
    newWindow.backgroundColor = .clear
    newWindow.isUserInteractionEnabled = false

    window = newWindow
    newWindow.isHidden = false
    newWindow.makeKeyAndVisible()
  }

  public func dismiss() {
    Task {
      guard currentLoadingCount > 0 else {
        return
      }

      currentLoadingCount -= 1

      guard currentLoadingCount == 0 else {
        return
      }

      dismissPublisher.send()

      Task.detached {
        try await Task.sleep(for: .seconds(2 * animationDuration))
        await self.hide()
      }
    }

  }

  func hide() {
    guard currentLoadingCount == 0 else {
      return
    }

    window?.isHidden = true
    window = nil
  }
}

private struct LoadingOverlayContainerView: View {
  let dismissPublisher: PassthroughSubject<Void, Never>

  @State
  var isVisible = false

  var body: some View {
    ZStack(alignment: .top) {
      Rectangle()
        .foregroundStyle(isVisible ? Color.ds.background.default.opacity(0.3) : .clear)

      if isVisible {
        DS.Draft.TidalIsland {
          ProgressView()
            .progressViewStyle(.indeterminate)
        }
        .transition(.tidalIsland)
      }
    }
    .onAppear {
      guard !isVisible else {
        return
      }

      withAnimation(.tidalIsland.delay(loadingAnimationDelay)) {
        isVisible = true
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .onReceive(dismissPublisher) { _ in
      guard isVisible else {
        return
      }

      withAnimation(.tidalIsland) {
        isVisible = false
      }
    }
  }
}

extension AnyTransition {
  fileprivate static var tidalIsland: AnyTransition {
    .asymmetric(
      insertion: .modifier(
        active: AppearModifier(isVisible: false), identity: AppearModifier(isVisible: true)),
      removal: .modifier(
        active: DisappearModifier(isVisible: false), identity: DisappearModifier(isVisible: true))
    )

  }
}

extension Animation {
  fileprivate static var tidalIsland: Animation {
    .snappy(duration: animationDuration, extraBounce: 0.20)
  }
}

private struct AppearModifier: ViewModifier {
  let isVisible: Bool

  func body(content: Content) -> some View {
    let scale = isVisible ? 1 : 0.8

    content
      .opacity(isVisible ? 1 : 0)
      .scaleEffect(x: scale, y: scale)
      .shadow(color: .black.opacity(isVisible ? 0.3 : 0), radius: 50, x: 0, y: 20)
  }
}

private struct DisappearModifier: ViewModifier {
  let isVisible: Bool

  func body(content: Content) -> some View {
    let scale = isVisible ? 1 : 0.8
    let blurRadius: Double = isVisible ? 0 : 13
    content
      .opacity(isVisible ? 1 : 0)
      .blur(radius: blurRadius)
      .scaleEffect(x: scale, y: scale)
  }
}

#Preview("Loading") {
  @Previewable @State
  var isLoading = false

  @Previewable @State
  var id: String = ""

  NavigationView {

    VStack(spacing: 16) {
      Infobox(
        "Do You Know?",
        description: """
          Lorem ipsum dolor sit amet, consectetur adipiscing elit.
          Sed euismod, arcu eget tincidunt condimentum, risus nunc dictum purus,
           vel ultricies nunc arcu id justo. Nullam auctor, nunc id ultricies tempus,
           libero elit ultricies nunc, ac lobortis orci nunc nec nunc
          """
      )
      .controlSize(.large)
      .style(mood: .positive)

      DS.TextField("Login", text: .constant(""))
      DS.PasswordField("Password", text: .constant(""))

      Spacer()
      Button(isLoading ? "Stop Loading" : "Show Loading") {
        isLoading.toggle()
        if !isLoading {
          Task {
            try await Task.sleep(for: .seconds(1))
          }
        }
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .neutral, intensity: .supershy)
      Spacer()

    }
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.top, 50)

    .loading(isLoading)
    .navigationTitle("Loading")
    .navigationBarTitleDisplayMode(.inline)
  }
}
