import Foundation
import Cocoa
import SwiftUI

final class SliderViewController: NSViewController {
    
    @Binding
    var currentValue: Double
    let minValue: Double
    let maxValue: Double
    
    lazy var slider: NSSlider = {
        let nsslider = NSSlider(value: currentValue,
                 minValue: minValue,
                 maxValue: maxValue,
                 target: self, action: #selector(lengthSliderValueChanged(_:)))
        nsslider.allowsTickMarkValuesOnly = true
        nsslider.sliderType = .linear
        return nsslider
    }()
    
    init(currentValue: Binding<Double>,
         minValue: Double,
         maxValue: Double) {
        self._currentValue = currentValue
        self.minValue = minValue
        self.maxValue = maxValue
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = slider
    }
    
    @objc func lengthSliderValueChanged(_ sender: NSSlider) {
        currentValue = sender.doubleValue
    }
}

struct SliderView: NSViewControllerRepresentable {

    @Binding
    var currentValue: Double
    let minValue: Double
    let maxValue: Double
    
    init(currentValue: Binding<Double>,
          minValue: Double,
          maxValue: Double) {
         self._currentValue = currentValue
         self.minValue = minValue
         self.maxValue = maxValue
    }

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<SliderView>
    ) -> SliderViewController {
        return SliderViewController(currentValue: $currentValue, minValue: minValue, maxValue: maxValue)
    }
    
    func updateNSViewController(
        _ nsViewController: SliderViewController,
        context: NSViewControllerRepresentableContext<SliderView>
    ) {

    }
}

struct SliderView_Previews: PreviewProvider {
    
    struct SliderExampleView: View {
        
        @State var currentValue: Double = 10
        
        var body: some View {
            VStack {
                Text("Current \(currentValue)")
                SliderView(currentValue: $currentValue,
                           minValue: 4,
                           maxValue: 40)
            }
        }
    }
    
    static var previews: some View {
        PopoverPreviewScheme {
            SliderExampleView()
        }
    }
}

