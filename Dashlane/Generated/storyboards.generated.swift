import Foundation
import UIKit

internal enum StoryboardScene {
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum PreAccountCreationOnboarding: StoryboardType {
    internal static let storyboardName = "PreAccountCreationOnboarding"

    internal static let preAccountCreationOnboardingController = SceneType<PreAccountCreationOnboardingController>(storyboard: PreAccountCreationOnboarding.self, identifier: "PreAccountCreationOnboardingController")

    internal static let preAccountCreationOnboardingPage = SceneType<PreAccountCreationOnboardingPage>(storyboard: PreAccountCreationOnboarding.self, identifier: "PreAccountCreationOnboardingPage")

    internal static let secureWifiOnboardingOne = SceneType<UIKit.UIViewController>(storyboard: PreAccountCreationOnboarding.self, identifier: "secureWifiOnboardingOne")
  }
  internal enum PreAccountCreationOnboardingiPad: StoryboardType {
    internal static let storyboardName = "PreAccountCreationOnboardingiPad"

    internal static let preAccountCreationOnboardingController = SceneType<PreAccountCreationOnboardingController>(storyboard: PreAccountCreationOnboardingiPad.self, identifier: "PreAccountCreationOnboardingController")

    internal static let preAccountCreationOnboardingPage = SceneType<PreAccountCreationOnboardingPage>(storyboard: PreAccountCreationOnboardingiPad.self, identifier: "PreAccountCreationOnboardingPage")
  }
}
internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
