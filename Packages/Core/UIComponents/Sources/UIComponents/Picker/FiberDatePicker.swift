#if canImport(UIKit)
  import Foundation
  import UIKit
  import UIDelight
  import SwiftUI

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

    @Binding
    var isPresented: Bool

    init(base: FiberDatePicker, isPresented: Binding<Bool>) {
      self.base = base
      self._isPresented = isPresented
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
      isPresented = false
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
        let datePicker = VoiceOverNotifiableDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = maximumDate
        datePicker.minimumDate = minimumDate
        datePicker.addTarget(
          coordinator,
          action: #selector(FiberDatePickerCoordinator.datePickerValueChanged(sender:)),
          for: .valueChanged)
        coordinator.picker = datePicker
        return datePicker
      }
    }
  }

  private class VoiceOverNotifiableDatePicker: UIDatePicker {

    override func didMoveToWindow() {
      guard UIAccessibility.isVoiceOverRunning else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
        UIAccessibility.post(notification: .layoutChanged, argument: self)
      }
    }
  }

#endif
