import Foundation
import Lottie

public struct LottieAsset: Hashable {
  public let lightAppearanceFile: String
  public let darkAppearanceFile: String
  public let bundle: Bundle

  public var hasDarkMode: Bool {
    return lightAppearanceFile != darkAppearanceFile
  }

  public init(
    file: String,
    bundle: Bundle = .main
  ) {
    self.lightAppearanceFile = file
    self.darkAppearanceFile = file
    self.bundle = bundle
  }

  public init(
    lightAppearanceFile: String,
    darkAppearanceFile: String,
    bundle: Bundle = .main
  ) {
    self.lightAppearanceFile = lightAppearanceFile
    self.darkAppearanceFile = darkAppearanceFile
    self.bundle = bundle
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(lightAppearanceFile)
    hasher.combine(darkAppearanceFile)
    hasher.combine(bundle.resourceURL?.path ?? "")
  }
}

#if canImport(SwiftUI)
  import SwiftUI

  extension LottieAsset {
    public func animation(for scheme: ColorScheme = .light) -> LottieAnimation! {
      guard let base = bundle.resourceURL else {
        return nil
      }

      if scheme == .dark {
        return LottieAnimation.filepath(
          base.appendingPathComponent(darkAppearanceFile).path,
          animationCache: DefaultAnimationCache.sharedCache)
      } else {
        return LottieAnimation.filepath(
          base.appendingPathComponent(lightAppearanceFile).path,
          animationCache: DefaultAnimationCache.sharedCache)
      }
    }

    fileprivate func animationKeyPairs() -> [(key: String, animation: LottieAnimation)] {
      if hasDarkMode {
        return [
          (lightAppearanceFile, animation(for: .light)),
          (darkAppearanceFile, animation(for: .dark)),
        ]
      } else {
        return [(lightAppearanceFile, animation(for: .light))]
      }
    }
  }

  extension DefaultAnimationCache {
    public func load(_ assets: [LottieAsset]) async {
      let animationKeyPairs = await Task.detached(priority: .utility) {
        assets.flatMap { $0.animationKeyPairs() }
      }.value

      for pair in animationKeyPairs {
        setAnimation(pair.animation, forKey: pair.key)
      }
    }
  }

#endif
