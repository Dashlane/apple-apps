#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import Combine

  struct FiberInlineDatePicker: UIViewRepresentable, FiberDatePicker {

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

    func makeUIView(context: Context) -> UIView {
      let picker = makePicker(from: context.coordinator)
      picker.backgroundColor = .ds.background.alternate
      if let date = date {
        picker.setDate(date)
      }
      return picker
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }

    func makeCoordinator() -> FiberDatePickerCoordinator {
      Coordinator(base: self, isPresented: $isPresented)
    }
  }
#endif
