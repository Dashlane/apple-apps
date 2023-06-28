import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif

class ConicalGradientLayer: CALayer {
        private struct Constants {
        static let MaxAngle: Double = 2 * .pi
        static let MaxHue = 255.0
    }

    private struct Transition {
        let fromLocation: Double
        let toLocation: Double

        let fromColor: CGColor
        let toColor: CGColor

        func color(forPercent percent: Double) -> CGColor {
            let normalizedPercent = percent.convert(fromMin: fromLocation, max: toLocation, toMin: 0.0, max: 1.0)
            return CGColor.lerp(from: fromColor.rgba, to: toColor.rgba, percent: CGFloat(normalizedPercent))
        }
    }

                var colors = [CGColor]() {
        didSet {
            setNeedsDisplay()
        }
    }

                    var locations = [Double]() {
        didSet {
            setNeedsDisplay()
        }
    }

        var startAngle: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

        var endAngle: Double = Constants.MaxAngle {
        didSet {
            setNeedsDisplay()
        }
    }

    private var transitions = [Transition]()

            override func draw(in ctx: CGContext) {
        ctx.saveGState()
        ctx.scaleBy(x: 2.0, y: 2.0)

        loadTransitions()
        let rect = ctx.boundingBoxOfClipPath
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let longerSide = max(rect.width, rect.height)
        let radius = Double(longerSide) * 2.squareRoot()
        let step = (.pi / 2) / radius
        var angle = startAngle

        while angle <= endAngle {
            let pointX = radius * sin(angle) + Double(center.x)
            let pointY = radius * cos(angle) + Double(center.y)
            let startPoint = CGPoint(x: pointX, y: pointY)

            let line = CGMutablePath()
            line.move(to: startPoint)
            line.addLine(to: center)
            ctx.addPath(line)
            ctx.setStrokeColor(color(forAngle: angle))
            ctx.strokePath()

            angle += step
        }
        ctx.restoreGState()

    }

    private func color(forAngle angle: Double) -> CGColor {
        let percent = angle.convert(fromZeroToMax: Constants.MaxAngle, toZeroToMax: 1.0)

        guard let transition = transition(forPercent: percent) else {
            return spectrumColor(forAngle: angle)
        }

        return transition.color(forPercent: percent)
    }

    private func spectrumColor(forAngle angle: Double) -> CGColor {
        let hue = angle.convert(fromZeroToMax: Constants.MaxAngle, toZeroToMax: Constants.MaxHue)
        return Color(hue: CGFloat(hue / Constants.MaxHue), saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
    }

    private func loadTransitions() {
        transitions.removeAll()

        if colors.count > 1 {
            let transitionsCount = colors.count - 1
            let locationStep = 1.0 / Double(transitionsCount)

            for index in 0 ..< transitionsCount {
                let fromLocation, toLocation: Double
                let fromColor, toColor: CGColor

                if locations.count == colors.count {
                    fromLocation = locations[index]
                    toLocation = locations[index + 1]
                } else {
                    fromLocation = locationStep * Double(index)
                    toLocation = locationStep * Double(index + 1)
                }

                fromColor = colors[index]
                toColor = colors[index + 1]

                let transition = Transition(fromLocation: fromLocation, toLocation: toLocation,
                                            fromColor: fromColor, toColor: toColor)
                transitions.append(transition)
            }
        }
    }

    private func transition(forPercent percent: Double) -> Transition? {
        let filtered = transitions.filter { percent >= $0.fromLocation && percent < $0.toLocation }
        let defaultTransition = percent <= 0.5 ? transitions.first : transitions.last
        return filtered.first ?? defaultTransition
    }

}

private extension Double {
    func convert(fromMin oldMin: Double, max oldMax: Double, toMin newMin: Double, max newMax: Double) -> Double {
        let oldRange, newRange, newValue: Double
        oldRange = (oldMax - oldMin)
        if oldRange == 0.0 {
            newValue = newMin
        } else {
            newRange = (newMax - newMin)
            newValue = (((self - oldMin) * newRange) / oldRange) + newMin
        }
        return newValue
    }

    func convert(fromZeroToMax oldMax: Double, toZeroToMax newMax: Double) -> Double {
        return ((self * newMax) / oldMax)
    }
}

private extension CGColor {
    struct RGBA {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        init(color: CGColor) {
            red = color.components?[0] ?? 0.0
            green = color.components?[1] ?? 0.0
            blue = color.components?[2] ?? 0.0
            alpha = color.components?[3] ?? 0.0
        }
    }

    var rgba: RGBA {
        return RGBA(color: self)
    }

    class func lerp(from: CGColor.RGBA, to: CGColor.RGBA, percent: CGFloat) -> CGColor {
        let red = from.red + percent * (to.red - from.red)
        let green = from.green + percent * (to.green - from.green)
        let blue = from.blue + percent * (to.blue - from.blue)
        let alpha = from.alpha + percent * (to.alpha - from.alpha)
        return Color(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }
}
