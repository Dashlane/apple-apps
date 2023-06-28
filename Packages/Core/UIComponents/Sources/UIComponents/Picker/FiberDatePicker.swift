#if canImport(UIKit)
import Foundation
import UIKit
import UIDelight

protocol DatePickerComponent: UIView {
    func setDate(_ date: Date)
    var selectedDate: Date? { get }
}

protocol FiberDatePicker {
    var date: Date? { get set }
    var maximumDate: Date? { get }
    var minimumDate: Date? { get }
    var mode: FiberDatePickerMode { get }
}

class FiberDatePickerCoordinator: NSObject {
    var base: FiberDatePicker
    var picker: DatePickerComponent?

    init(base: FiberDatePicker) {
        self.base = base
    }

    @objc func datePickerValueChanged(sender: UIDatePicker) {
        base.date = sender.date
    }

    @objc func onDoneButtonTapped(sender: UIBarButtonItem) {
        if let picker = picker {
            base.date = picker.selectedDate
        }
        #if !EXTENSION
        UIApplication.shared.endEditing()
        #endif
    }
}

public enum FiberDatePickerMode {
    case monthAndYear
    case `default`
}

extension FiberDatePicker {

    func makePicker(from coordinator: FiberDatePickerCoordinator) -> DatePickerComponent {
        switch mode {
        case .monthAndYear:
            let picker = MonthYearPicker(frame: CGRect(), coordinator: coordinator)
            coordinator.picker = picker
            return picker
        case .default:
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.maximumDate = maximumDate
            datePicker.minimumDate = minimumDate
            datePicker.addTarget(coordinator,
                                 action: #selector(FiberDatePickerCoordinator.datePickerValueChanged(sender:)),
                                 for: .valueChanged)
            coordinator.picker = datePicker
            return datePicker
        }
    }
}
#endif
