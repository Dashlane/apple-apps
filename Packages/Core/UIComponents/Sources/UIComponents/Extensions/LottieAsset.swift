import Foundation
import Lottie

public struct LottieAsset: Hashable {
    public let lightAppearanceFile: String
    public let darkAppearanceFile: String
    public let bundle: Bundle
    
    public var hasDarkMode: Bool {
        return lightAppearanceFile != darkAppearanceFile
    }
    
    public init(file: String,
                bundle: Bundle = .main) {
        self.lightAppearanceFile = file
        darkAppearanceFile = file
        self.bundle = bundle
    }
  
    public init(lightAppearanceFile: String,
                darkAppearanceFile: String,
                bundle: Bundle = .main) {
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

#if canImport(UIKit)
import UIKit

extension LottieAsset {
    public func animation(for userInterfaceStyle: UIUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle, cache: AnimationCacheProvider? = nil) -> LottieAnimation! {
        guard let base = bundle.resourceURL else {
            return nil
        }

        if userInterfaceStyle == .dark {
            return LottieAnimation.filepath(base.appendingPathComponent(lightAppearanceFile).path, animationCache: cache)
        } else {
            return LottieAnimation.filepath(base.appendingPathComponent(lightAppearanceFile).path, animationCache: cache)
        }
    }
    
    fileprivate func animationKeyPairs() -> [(key: String, animation: LottieAnimation)] {
        if hasDarkMode {
            return [(lightAppearanceFile, animation(for: .light)),(darkAppearanceFile, animation(for: .dark))]
        }
        else {
            return [(lightAppearanceFile, animation(for: .light))]
        }
    }
}

extension Collection where Element == LottieAsset {
    public func preloadInBackground() {
        DispatchQueue.global(qos: .utility).async {
            let animationKeyPairs = flatMap({ $0.animationKeyPairs() })
            DispatchQueue.main.async {
                for pair in animationKeyPairs {
                    DefaultAnimationCache.sharedCache.setAnimation(pair.animation, forKey: pair.key)
                }
            }
        }
    }
}

#endif
