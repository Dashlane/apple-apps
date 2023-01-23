import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif

class ShieldLayer: CAShapeLayer, CALayerDelegate, CAAnimationDelegate {

    static let sourcePath: CGPath = {
        let bezier  = CGMutablePath()

        bezier.move(to: CGPoint(x: 66.44, y: 152))
        bezier.addCurve(to: CGPoint(x: 133, y: 123.81), control1: CGPoint(x: 88.62, y: 142.6), control2: CGPoint(x: 110.8, y: 133.17))
        bezier.addCurve(to: CGPoint(x: 117.21, y: 48.18), control1: CGPoint(x: 133.02, y: 97.92), control2: CGPoint(x: 131.24, y: 70.83))
        bezier.addCurve(to: CGPoint(x: 66.52, y: 0), control1: CGPoint(x: 105.04, y: 28), control2: CGPoint(x: 87.08, y: 11.41))
        bezier.addCurve(to: CGPoint(x: 1.82, y: 89.87), control1: CGPoint(x: 33.22, y: 18.34), control2: CGPoint(x: 5.87, y: 51.22))
        bezier.addCurve(to: CGPoint(x: 0, y: 123.82), control1: CGPoint(x: 0.35, y: 101.12), control2: CGPoint(x: 0.01, y: 112.49))
        bezier.addCurve(to: CGPoint(x: 66.44, y: 152), control1: CGPoint(x: 22.15, y: 133.22), control2: CGPoint(x: 44.29, y: 142.61))

        return bezier
    }()

    var completion: (() -> Void)?
    open var progress: CGFloat = 0 {
        didSet {
            let limit = (1 - strokeStart)
            if progress > limit {
                strokeEnd = limit
            } else {
                strokeEnd = progress
            }
        }
    }

    public override init() {
        super.init()

        delegate = self as CALayerDelegate
        path = ShieldLayer.sourcePath
        fillColor = Color.clear.cgColor
        lineCap = CAShapeLayerLineCap.round
        strokeStart = 0
        strokeEnd   = 0
    }
    override var frame: CGRect {
        didSet {
            updatePath()
        }
    }
    override var lineWidth: CGFloat {
        didSet {
            updatePath()
        }
    }

    private func updatePath() {
        let path = ShieldLayer.sourcePath
        let offset = lineWidth / 2
        let scaleX = (frame.width - lineWidth) / (path.boundingBox.width)
        let scaleY = (frame.height  - lineWidth) / (path.boundingBox.height)
        var transform = CGAffineTransform(translationX: offset, y: offset).scaledBy(x: scaleX, y: scaleY)

        let transformedPath = path.copy(using: &transform)
        self.path = transformedPath
        strokeStart = lineWidth / (4 * .pi * max(transformedPath!.boundingBoxOfPath.width, transformedPath!.boundingBoxOfPath.height) )
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    open func animateProgress(_ progress: CGFloat, duration: CGFloat, completion: (() -> Void)? = nil) {
        removeAllAnimations()
        let progress             = progress
        let animation            = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue      = strokeEnd
        animation.toValue        = progress
        animation.duration       = CFTimeInterval(duration)
        animation.delegate       = self as CAAnimationDelegate
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        strokeEnd                = progress
        add(animation, forKey: "strokeEnd")
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            completion?()
        }
    }
}
