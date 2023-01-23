#if canImport(UIKit)

import SwiftUI
import UIKit
import Lottie

public struct LottieView: UIViewRepresentable {

    public enum State: Equatable {
        public static func == (lhs: LottieView.State, rhs: LottieView.State) -> Bool {
            switch (lhs, rhs) {
            case (.regular, .regular):
                return true
            case (let .marker(leftMarker), let .marker(rightMarker)):
                return leftMarker == rightMarker
            case (let .finish(leftSpeed, _), let .finish(rightSpeed, _)):
                return leftSpeed == rightSpeed
            case (let .progress(leftFrom, leftTo), let .progress(rightFrom, rightTo)):
                return leftFrom == rightFrom && leftTo == rightTo
            default:
                return false
            }
        }

        case regular
        case progress(fromProgress: AnimationProgressTime, toProgress: AnimationProgressTime)
        case marker(toMarker: String)
        case finish(animationSpeed: CGFloat = 1.0, onComplete: () -> Void)
    }

    public struct DynamicAnimationProperty {
        let valueProvider: AnyValueProvider
        let keypath: AnimationKeypath

        public init(color: UIColor, keypath: String) {
            self.valueProvider = ColorValueProvider(color.lottieColorValue)
            self.keypath = AnimationKeypath(keypath: keypath)
        }
    }
    
        public let asset: LottieAsset

            public let aspectRatio: CGFloat

    private let animation: LottieAnimation?
    private let loopMode: LottieLoopMode
    private let contentMode: UIView.ContentMode
    private let animated: Bool
    private var dynamicAnimationProperties: [DynamicAnimationProperty]?
    private let state: State

    public init(_ asset: LottieAsset,
                loopMode: LottieLoopMode = .loop,
                contentMode: UIView.ContentMode = .scaleAspectFit,
                animated: Bool = true,
                dynamicAnimationProperties: [DynamicAnimationProperty]? = nil,
                state: State = .regular) {
        self.asset = asset
                self.animation = asset.animation(for: UITraitCollection.current.userInterfaceStyle, cache: DefaultAnimationCache.sharedCache)

        self.loopMode = loopMode
        self.state = state
        self.contentMode = contentMode
        self.animated = animated
        self.aspectRatio = (animation?.bounds.width ?? .zero) / (animation?.bounds.height ?? .zero)
        self.dynamicAnimationProperties = dynamicAnimationProperties
    }

    public func makeUIView(context: Context) -> UIView {
        let animationView = LottieAnimationView()
        animationView.animation = animation
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false

        dynamicAnimationProperties?.forEach {
            animationView.setValueProvider($0.valueProvider, keypath: $0.keypath)
        }

        let view = UIView()
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        configure(animationView)

        return view
    }

    public func updateUIView(_ view: UIView, context: Context) {
        guard let animationView = view.subviews.first as? LottieAnimationView
            else { return }
        configure(animationView)
    }

    public func configure(_ animationView: LottieAnimationView) {
        if animated && animationView.shouldBePlaying && !animationView.isAnimationPlaying {
            if case let .progress(fromProgress, toProgress) = state {
                animationView.play(fromProgress: fromProgress, toProgress: toProgress)
            } else if case let .marker(toMarker) = state {
                animationView.play(toMarker: toMarker)
            } else {
                animationView.play()
            }
        } else if animationView.isAnimationPlaying && !animated {
            animationView.stop()
            animationView.currentProgress = 0
        } else if case let .finish(animationSpeed, completion) = state, animationView.isAnimationPlaying {
            animationView.animationSpeed = animationSpeed
            animationView.loopMode = .playOnce
            animationView.play { _ in
                completion()
            }
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

#endif
