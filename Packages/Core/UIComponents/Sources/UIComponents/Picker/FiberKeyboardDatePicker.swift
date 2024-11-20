#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import Combine
  import DesignSystem

  struct FiberKeyboardDatePicker: UIViewRepresentable, FiberDatePicker {

    typealias Coordinator = FiberDatePickerCoordinator

    @Binding
    var date: Date?

    @Binding
    var isPresented: Bool

    let dateFormatter: DateFormatter
    let maximumDate: Date?
    let minimumDate: Date?
    let mode: FiberDatePickerMode

    init(
      _ date: Binding<Date?>,
      isPresented: Binding<Bool>,
      dateFormatter: DateFormatter,
      mode: FiberDatePickerMode,
      maximumDate: Date? = nil,
      minimumDate: Date? = nil
    ) {
      self._date = date
      self._isPresented = isPresented
      self.dateFormatter = dateFormatter
      self.mode = mode
      self.maximumDate = maximumDate
      self.minimumDate = minimumDate
    }

    func makeUIView(context: Context) -> NoCursorTextField {
      let textField = NoCursorTextField()
      configure(textField, with: context.coordinator)
      return textField
    }

    private func configure(_ textField: UITextField, with coordinator: Coordinator) {
      let picker = makePicker(from: coordinator)
      update(textField)
      picker.backgroundColor = .ds.background.alternate

      let toolbarFrame = CGRect(
        x: 0, y: 0,
        width: UIScreen.main.bounds.size.width, height: 44)
      let accessoryToolbar = UIToolbar(frame: toolbarFrame)
      accessoryToolbar.backgroundColor = .ds.background.alternate
      let doneButton = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: coordinator,
        action: #selector(Coordinator.onDoneButtonTapped(sender:)))
      doneButton.tintColor = .ds.text.brand.standard
      let flexibleSpace = UIBarButtonItem(
        barButtonSystemItem: .flexibleSpace,
        target: nil,
        action: nil)
      accessoryToolbar.items = [flexibleSpace, doneButton]
      textField.inputView = picker
      textField.inputAccessoryView = accessoryToolbar
    }

    func updateUIView(_ textField: NoCursorTextField, context: Context) {
      update(textField)
    }

    func update(_ textField: UITextField) {
      guard let picker = textField.inputView as? DatePickerComponent else {
        return
      }

      if let date = date {
        textField[\.text] = dateFormatter.string(from: date)
        picker.setDate(date)
      } else {
        textField[\.text] = ""
      }
    }

    func makeCoordinator() -> FiberDatePickerCoordinator {
      Coordinator(base: self, isPresented: $isPresented)
    }
  }

  extension UIDatePicker: DatePickerComponent {
    func setDate(_ date: Date) {
      self[\.date] = date
    }

    var selectedDate: Date? {
      return date
    }
  }

  class NoCursorTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
      return CGRect.zero
    }
  }
#endif
