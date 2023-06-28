#if os(macOS)
import Cocoa
public typealias View = NSView
public typealias Color = NSColor
#else
import UIKit
public typealias View = UIView
public typealias Color = UIColor
#endif

@IBDesignable
public class ShieldScoreView: View {
    @IBInspectable public var startAngle: CGFloat = 90 { didSet {  self.resetLayersProperties() } }
    @IBInspectable public var width: CGFloat = 6 { didSet {  self.resetLayersProperties() } }
    @IBInspectable public var backgroundWidth: CGFloat = 4 { didSet {  self.resetLayersProperties() } }

    #if os(macOS) 
    @IBInspectable public var backgroundBarColor: NSColor = .gray { didSet {  self.resetLayersProperties() } }
    #else
    @IBInspectable public var backgroundBarColor: UIColor = .gray { didSet {  self.resetLayersProperties() } }
    #endif

    @IBInspectable public var progressAnimationDuration: CGFloat = 0.25

    #if os(macOS) 
    @IBInspectable public var animationBarColor: NSColor = .blue { didSet {  self.resetLayersProperties() } }
    #else
    @IBInspectable public var animationBarColor: UIColor = .blue { didSet {  self.resetLayersProperties() } }
    #endif

    @IBInspectable public var animationDuration: Double = 2.0

        @IBInspectable
    open var progress: CGFloat {
        get {
            return barLayer.strokeEnd
        }
        set {
            updateColors(forProgress: newValue)
            barLayer.animateProgress(newValue, duration: progressAnimationDuration)
        }
    }

    private var barLayer = ShieldLayer()
    private var barGradient = ConicalGradientLayer()
    private var backgroundBar = ShieldLayer()
    private var animationBackgroundBar = ShieldLayer()
    public private(set) var isAnimating: Bool = false

        override public init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        setup()
        resetLayersProperties()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        resetLayersProperties()
    }

    override public func prepareForInterfaceBuilder() {
        setup()
        resetLayersProperties()
    }

    #if os(macOS)
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if isAnimating {
            startAnimating()
        }
    }
    #else
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if isAnimating {
            startAnimating()
        }
    }
    #endif

        private func setup() {
        #if os(macOS)
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundBar)
        self.layer?.addSublayer(barGradient)
        self.layer?.addSublayer(animationBackgroundBar)

        #else
        self.layer.isGeometryFlipped = true
        self.layer.addSublayer(backgroundBar)
        self.layer.addSublayer(barGradient)
        self.layer.addSublayer(animationBackgroundBar)
        #endif
    }

    private func resetLayersProperties() {
        let currentProgress = progress
        updateColors(forProgress: currentProgress)

        barLayer.lineWidth = width
        barLayer.strokeColor = Color.black.cgColor
        barLayer.frame = bounds
        barLayer.progress = currentProgress

        backgroundBar.progress = 1.0
        backgroundBar.lineWidth = backgroundWidth
        backgroundBar.strokeColor = backgroundBarColor.cgColor
        let inset = (width - backgroundWidth) / 2
        backgroundBar.frame = bounds.insetBy(dx: inset, dy: inset)

        barGradient.frame = bounds
        barGradient.mask = barLayer
        barGradient.startAngle = -0.01 * 360 * .pi / 180
        barGradient.endAngle = 0.99 * 360 * .pi / 180
        barGradient.isHidden = false

        animationBackgroundBar.isHidden = true
        animationBackgroundBar.frame =  barLayer.frame
        animationBackgroundBar.lineWidth = barLayer.lineWidth
        animationBackgroundBar.strokeColor = animationBarColor.cgColor
        animationBackgroundBar.progress = 1.0
    }

    private func updateColors(forProgress progress: CGFloat) {
        barGradient.locations =  [0, Double(progress)]

        switch Int(progress * 100) {
        case 0..<60:
            barGradient.colors = [#colorLiteral(red: 1, green: 0.568627451, blue: 0.6235294118, alpha: 1), #colorLiteral(red: 1, green: 0.03921568627, blue: 0.2078431373, alpha: 1)]
        case 60..<90:
            barGradient.colors = [#colorLiteral(red: 1, green: 0.8666666667, blue: 0.6705882353, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.5215686275, blue: 0.3215686275, alpha: 1)]
        case 90..<99:
            barGradient.colors = [#colorLiteral(red: 0.8, green: 0.8980392157, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 0.4078431373, green: 0.8, blue: 0.4117647059, alpha: 1)]
        default:
            barGradient.colors = [#colorLiteral(red: 0.4078431373, green: 0.8, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.4078431373, green: 0.8, blue: 0.4117647059, alpha: 1)]
        }
    }

        private func animateProgress(_ progress: CGFloat, duration: CGFloat, completion: (() -> Void)? = nil) {
        barLayer.animateProgress(progress, duration: duration, completion: completion)
    }

    public func startAnimating() {
        guard animationBackgroundBar.animation(forKey: "stroke") == nil else {
            return
        }
        isAnimating = true
        barGradient.isHidden = true
        animationBackgroundBar.isHidden = false
        let timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]

        let endPointAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        endPointAnimation.values = [0.0, 1]
        endPointAnimation.duration = animationDuration * 2 / 3
        endPointAnimation.timingFunctions = timingFunctions

        let startPointAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        startPointAnimation.values = [0.0, 1.0]
        startPointAnimation.duration = animationDuration * 2 / 3
        startPointAnimation.beginTime = animationDuration * 1 / 3
        startPointAnimation.timingFunctions = timingFunctions

        let group = CAAnimationGroup()
        group.animations = [endPointAnimation, startPointAnimation]
        group.duration = animationDuration
        group.repeatCount = Float.infinity

        animationBackgroundBar.add(group, forKey: "stroke")
    }

    public func stopAnimating() {
        isAnimating = false
        barGradient.isHidden = false
        animationBackgroundBar.isHidden = true
        animationBackgroundBar.removeAllAnimations()
    }
}
