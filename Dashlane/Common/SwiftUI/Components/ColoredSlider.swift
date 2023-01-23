import SwiftUI

struct ColoredSlider: UIViewRepresentable {

    final class Coordinator: NSObject {
        var value: Binding<Double>
        var step: Float

        init(value: Binding<Double>, step: Float) {
            self.value = value
            self.step = step
        }

        @objc func valueChanged(_ sender: UISlider) {
            let roundedValue = round(sender.value/step) * step
            sender.value = roundedValue

            self.value.wrappedValue = Double(sender.value)
        }
    }

    var thumbColor: UIColor = .white
    var minTrackColor: UIColor?
    var maxTrackColor: UIColor?
    var range: ClosedRange<Float> = 0...100
    var step: Float = 1.0

    @Binding var value: Double

    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.value = Float(value)
        slider.minimumValue = range.lowerBound
        slider.maximumValue = range.upperBound

        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )

        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView[\.value] = Float(self.value)
    }

    func makeCoordinator() -> ColoredSlider.Coordinator {
        Coordinator(value: $value, step: step)
    }
}

#if DEBUG
struct SwiftUISlider_Previews: PreviewProvider {
    static var previews: some View {
        ColoredSlider(
            thumbColor: .white,
            minTrackColor: .blue,
            maxTrackColor: .green,
            range: 4...32,
            value: .constant(0.5)
        )
    }
}
#endif
