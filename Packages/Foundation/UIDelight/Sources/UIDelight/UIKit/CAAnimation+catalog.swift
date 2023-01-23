import Foundation

#if canImport(UIKit)
import UIKit

public extension CAAnimation {
    func delayed(by delay: TimeInterval) -> CAAnimation {
        let animation = self.copy() as! CAAnimation
        animation.beginTime = delay
        animation.fillMode = CAMediaTimingFillMode.both
        if animation.duration == 0 {
            animation.duration = CATransaction.value(forKey: kCATransactionAnimationDuration) as! Double
        }
        let group = CAAnimationGroup()
        group.animations = [animation]
        group.duration = (animation.duration + delay) / Double(animation.speed)
        group.fillMode = CAMediaTimingFillMode.both
        group.isRemovedOnCompletion = animation.isRemovedOnCompletion
        return group
    }

        static var fadeIn: CABasicAnimation {
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.fillMode = CAMediaTimingFillMode.both
        return fade
    }

    static var fadeOut: CABasicAnimation {
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.toValue = 0
        fade.speed = 1.2
        fade.fillMode = CAMediaTimingFillMode.both
        fade.isRemovedOnCompletion = false
        return fade
    }

        enum SlideDirection {
        case top, bottom, left, right

        fileprivate var offset: CGPoint {
            switch self {

            case .top:
                return CGPoint(x: 0, y: -1)
            case .bottom:
                return CGPoint(x: 0, y: 1)
            case .left:
                return CGPoint(x: -1, y: 1)
            case .right:
                return CGPoint(x: 1, y: 0)
            }
        }
    }

    static func slide(from offset: CGPoint) -> CAAnimation {
        let slide = CABasicAnimation(keyPath: "position")
        slide.isAdditive = true
        slide.fromValue = NSValue(cgPoint: offset)
        slide.toValue = NSValue(cgPoint: CGPoint.zero)
        slide.fillMode = CAMediaTimingFillMode.both
        slide.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return slide
    }

    static func slide(to offset: CGPoint) -> CAAnimation {
        let slide = CABasicAnimation(keyPath: "position")
        slide.isAdditive = true
        slide.fromValue = NSValue(cgPoint: CGPoint.zero)
        slide.toValue = NSValue(cgPoint: offset)
        slide.fillMode = CAMediaTimingFillMode.both
        slide.isRemovedOnCompletion = false
        slide.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return slide
    }

    static func slideIn(with direction: SlideDirection, containerSize: CGSize, shouldFade: Bool) -> CAAnimation {
        var offset = direction.offset
        offset.x *= containerSize.width
        offset.y *= containerSize.height
        let slide = slide(from: offset)
        slide.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)

        let anim = CAAnimationGroup()
        anim.fillMode = CAMediaTimingFillMode.both
        anim.animations = shouldFade ? [slide, fadeIn] : [slide]
        return anim
    }

    static func slideOut(with direction: SlideDirection, containerSize: CGSize, shouldFade: Bool) -> CAAnimation {
        var offset = direction.offset
        offset.x *= containerSize.width
        offset.y *= containerSize.height
        let slide = slide(to: offset)
        slide.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)

        let anim = CAAnimationGroup()
        anim.fillMode = CAMediaTimingFillMode.both
        anim.isRemovedOnCompletion = false
        anim.animations = shouldFade ? [slide, fadeOut] : [slide]
        return anim
    }
}

#endif
