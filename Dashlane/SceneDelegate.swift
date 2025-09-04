import LoginKit
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var coordinator: AppCoordinator?

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    let appLaunchTimeStamp = Date().timeIntervalSince1970

    if let windowScene = scene as? UIWindowScene {
      windowScene.hideTitleFromTitleBarIfNeeded()
      let crashReporter = SentryCrashReporter(target: .app)
      let window = UIWindow(windowScene: windowScene)
      self.window = window
      Task {
        let appCoordinator = await AppCoordinator(
          window: window,
          crashReporter: crashReporter,
          appLaunchTimeStamp: appLaunchTimeStamp)
        coordinator = appCoordinator
        appCoordinator.start()
        self.handleExternalLaunches(for: scene, options: connectionOptions)
      }
    } else {
      fatalError()
    }
  }

  func handleExternalLaunches(
    for scene: UIScene, options connectionOptions: UIScene.ConnectionOptions
  ) {
    if let userActivity = connectionOptions.userActivities.first {
      self.scene(scene, continue: userActivity)
    } else {
      self.scene(scene, openURLContexts: connectionOptions.urlContexts)
    }
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
  }

  func sceneWillResignActive(_ scene: UIScene) {
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
  }

  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard let coordinator = coordinator else { return }
    coordinator.appServices.deepLinkingService.handle(userActivity)
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    guard let coordinator = coordinator else { return }
    coordinator.appServices.deepLinkingService.handleURL(url)
  }
}

extension UIWindowScene {

  fileprivate func hideTitleFromTitleBarIfNeeded() {
    #if targetEnvironment(macCatalyst)
      guard let titlebar = self.titlebar else { return }
      titlebar.titleVisibility = .hidden
      titlebar.toolbar = nil
    #endif
  }
}
