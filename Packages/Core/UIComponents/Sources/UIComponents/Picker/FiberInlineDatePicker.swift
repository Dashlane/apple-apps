#if canImport(UIKit)
import Foundation
import SwiftUI
import Combine

struct FiberInlineDatePicker: UIViewRepresentable, FiberDatePicker {

    typealias Coordinator = FiberDatePickerCoordinator

    @Binding
    var date: Date?

    let dateFormatter: DateFormatter
    let maximumDate: Date?
    let minimumDate: Date?
    let mode: FiberDatePickerMode

    init(_ date: Binding<Date?>,
         dateFormatter: DateFormatter,
         mode: FiberDatePickerMode,
         maximumDate: Date? = nil,
         minimumDate: Date? = nil) {
        self._date = date
        self.dateFormatter = dateFormatter
        self.mode = mode
        self.maximumDate = maximumDate
        self.minimumDate = minimumDate
    }

    func makeUIView(context: Context) -> UIView {
        let picker = makePicker(from: context.coordinator)
        picker.backgroundColor = UIColor.systemBackground
        if let date = date {
            picker.setDate(date)
        }
        return picker
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }

    func makeCoordinator() -> FiberDatePickerCoordinator {
        Coordinator(base: self)
    }
}
#endif
