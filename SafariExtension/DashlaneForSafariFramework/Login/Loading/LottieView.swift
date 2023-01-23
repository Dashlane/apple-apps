import SwiftUI
import Foundation
import Lottie


struct DynamicAnimationProperty {
    let valueProvider: AnyValueProvider
    let keypath: AnimationKeypath
    
    init(color: NSColor, keypath: String) {
        self.valueProvider = ColorValueProvider(color.lottieColorValue)
        self.keypath = AnimationKeypath(keypath: keypath)
    }
}

private class BundleClass { }

struct LottieView: NSViewRepresentable {

    public enum LottieStyle {
        case isDarkModeCompatible(name: String)
        case coloredAnimation(name: String, lightMode: NSColor, darkMode: NSColor)
    }

    var type: LottieStyle

        var aspectRatio: CGFloat

    private let animation: LottieAnimation?
    private let loopMode: LottieLoopMode
    private let animated: Bool
    private let contentMode: LottieContentMode
    private var dynamicAnimationProperties: [DynamicAnimationProperty]?
    private let fromProgress: AnimationProgressTime?
    private let toProgress: AnimationProgressTime?

    init(type: LottieStyle,
         loopMode: LottieLoopMode = .loop,
         animated: Bool = true,
         contentMode: LottieContentMode = .scaleAspectFill,
         dynamicAnimationProperties: [DynamicAnimationProperty]? = nil,
         fromProgress: AnimationProgressTime? = nil,
         toProgress: AnimationProgressTime? = nil) {

        self.type = type
        switch type {
        case let .isDarkModeCompatible(name) :
            self.animation = LottieAnimation.darkModeCompatibleAnimation(withName: name, in:
                                                                                Bundle(for: BundleClass.self))
        case let .coloredAnimation(name, _, _):
            self.animation = LottieAnimation.named(name, bundle: Bundle(for: BundleClass.self), animationCache: LRUAnimationCache.sharedCache)
        }
        self.loopMode = loopMode
        self.contentMode = contentMode
        self.animated = animated
        self.aspectRatio = (animation?.bounds.width ?? .zero) / (animation?.bounds.height ?? .zero)
        self.dynamicAnimationProperties = dynamicAnimationProperties
        self.fromProgress = fromProgress
        self.toProgress = toProgress
    }

    func makeNSView(context: Context) -> NSView {
        let animationView = LottieAnimationView()
        animationView.animation = animation
        animationView.contentMode = LottieContentMode.scaleAspectFill
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false

        dynamicAnimationProperties?.forEach {
            animationView.setValueProvider($0.valueProvider, keypath: $0.keypath)
        }

        let view = NSView()
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        configure(animationView)

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let animationView = nsView.subviews.first as? LottieAnimationView
        else { return }
        configure(animationView)
    }

    func configure(_ animationView: LottieAnimationView) {
        if case let .coloredAnimation(_, lightMode, darkMode) = self.type {
            animationView.updateAppearanceRelatedChanges(lightMode: lightMode, darkMode: darkMode)
        }
        if animated && animationView.shouldBePlaying && !animationView.isAnimationPlaying {
            if let fromProgress = fromProgress, let toProgress = toProgress {
                animationView.play(fromProgress: fromProgress, toProgress: toProgress)
            } else {
                animationView.play()
            }
        } else if animationView.isAnimationPlaying && !animated {
            animationView.stop()
            animationView.currentProgress = 0
        }
    }
}

private extension LottieAnimationView {
     var shouldBePlaying: Bool {
        if self.loopMode == .playOnce {
            return self.currentProgress != 1
        }

        return true
    }
}

public extension NSColor {

    var lottieColorValue: LottieColor {
        return LottieColor(r: Double(self.redComponent), g: Double(self.greenComponent), b: Double(self.blueComponent), a: Double(self.alphaComponent))
  }

}

public extension LottieAnimationView {
    func updateAppearanceRelatedChanges(lightMode: NSColor, darkMode: NSColor) {
        switch NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua?:
            guard let color = darkMode.usingColorSpace(.genericRGB) else {
                return
            }
            self.setValueProvider(ColorValueProvider(LottieColor(r: Double(color.redComponent), g: Double(color.greenComponent), b: Double(color.blueComponent), a: 1)), keypath: .init(keypath: "**.Color"))
        default:
            guard let color = lightMode.usingColorSpace(.genericRGB) else {
                return
            }
            self.setValueProvider(ColorValueProvider(LottieColor(r: Double(color.redComponent), g: Double(color.greenComponent), b: Double(color.blueComponent), a: 1)), keypath: .init(keypath: "**.Color"))
        }
    }
}

extension LottieAnimation {
    class func darkModeCompatibleAnimation(withName name: String, in bundle: Bundle) -> LottieAnimation? {
        if NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua && LottieAnimation.hasDarkAnimation(withName: name, in: bundle) {
            return LottieAnimation.named("\(name)_Dark", bundle: bundle)
        }

        return LottieAnimation.named("\(name)_Light", bundle: bundle)
    }

    private class func hasDarkAnimation(withName name: String, in bundle: Bundle) -> Bool {
        return bundle.path(forResource: "\(name)_Dark", ofType: "json") != nil
    }
}
