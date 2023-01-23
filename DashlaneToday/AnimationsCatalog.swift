import Foundation
import UIKit

struct AnimationsCatalog {
    
    static func slideAnimation(from offset: CGPoint) -> CAAnimation {
        let slide = CABasicAnimation(keyPath: "position")
        slide.isAdditive = true
        slide.fromValue = offset
        slide.toValue = CGPoint.zero
        slide.fillMode = CAMediaTimingFillMode.both
        slide.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return slide
    }
    
    static func slideAnimation(to offset: CGPoint) -> CAAnimation {
        let slide = CABasicAnimation(keyPath: "position")
        slide.isAdditive = true
        slide.fromValue = CGPoint.zero
        slide.toValue = offset
        slide.fillMode = CAMediaTimingFillMode.both
        slide.isRemovedOnCompletion = false
        slide.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return slide
    }
    
    static var fadeInAnimation: CAAnimation {
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.fillMode = CAMediaTimingFillMode.both
        return fade
    }
    
    static var fadeOutAnimation: CAAnimation {
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.toValue = 0
        fade.fillMode = CAMediaTimingFillMode.both
        fade.isRemovedOnCompletion = false
        return fade
    }
    
    static func unitOffset(transitionType: CATransitionSubtype) -> CGPoint {
        switch(transitionType) {
        case .fromBottom:
            return CGPoint(x: 0, y: 1)
        case .fromTop:
            return CGPoint(x: 0, y: -1)
        case .fromLeft:
            return CGPoint(x: -1, y: 0)
        case .fromRight:
            return CGPoint(x: 1, y: 0)
        default:
            return CGPoint.zero
        }
    }
    
    static func slideIn(direction transitionType: CATransitionSubtype, containerSize: CGSize, fadeOn: Bool = true) -> CAAnimation {
        var offset = unitOffset(transitionType: transitionType)
        offset.x *= containerSize.width
        offset.y *= containerSize.height
        let slide = slideAnimation(from: offset)
        slide.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        let fade = fadeInAnimation
        let anim = CAAnimationGroup()
        anim.fillMode = CAMediaTimingFillMode.both
        anim.animations = fadeOn ? [slide, fade] : [slide]
        return anim
    }
    
    static func slideOut(direction transitionType: CATransitionSubtype, containerSize: CGSize, fadeOn: Bool = true) -> CAAnimation {
        var offset = unitOffset(transitionType: transitionType)
        offset.x *= containerSize.width
        offset.y *= containerSize.height
        let slide = slideAnimation(to: offset)
        slide.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        let fade = fadeOutAnimation
        fade.speed = 1.2
        let anim = CAAnimationGroup()
        anim.fillMode = CAMediaTimingFillMode.both
        anim.isRemovedOnCompletion = false
        anim.animations = fadeOn ? [slide, fade] : [slide]
        return anim
    }
    
    
}

