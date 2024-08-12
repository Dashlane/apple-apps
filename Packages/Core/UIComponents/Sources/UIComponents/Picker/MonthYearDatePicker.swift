#if canImport(UIKit)
  import Foundation
  import UIKit

  class MonthYearPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource,
    DatePickerComponent
  {
    enum Components: Int {
      case month
      case year
    }

    let coordinator: FiberDatePickerCoordinator

    let calendar = Calendar.current

    lazy var monthSymbols: [String] = {
      let dateFormatter = DateFormatter()
      return dateFormatter.monthSymbols
    }()

    var minimumDate: Date {
      if let date = coordinator.base.minimumDate, let selectedDate = coordinator.base.date {
        return min(date, selectedDate)
      } else {
        return coordinator.base.minimumDate ?? .distantPast
      }
    }

    var maximumDate: Date {
      if let date = coordinator.base.maximumDate, let selectedDate = coordinator.base.date {
        return max(date, selectedDate)
      } else {
        return coordinator.base.maximumDate ?? .distantFuture
      }
    }

    var selectedDate: Date? {
      let monthIndex = selectedRow(inComponent: Components.month.rawValue)
      let yearIndex = selectedRow(inComponent: Components.year.rawValue)
      return makeDate(from: monthIndex, and: yearIndex)
    }

    init(frame: CGRect, coordinator: FiberDatePickerCoordinator) {
      self.coordinator = coordinator
      super.init(frame: frame)
      self.delegate = self
      self.dataSource = self
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 2
    }

    override func didMoveToWindow() {
      guard UIAccessibility.isVoiceOverRunning else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
        UIAccessibility.post(notification: .layoutChanged, argument: self)
      }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      switch component {
      case Components.month.rawValue:
        return 12
      case Components.year.rawValue:
        let minYear = calendar.component(.year, from: minimumDate)
        let maxYear = calendar.component(.year, from: maximumDate)
        return maxYear - minYear + 1
      default:
        return 0
      }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
      -> String?
    {
      switch component {
      case Components.month.rawValue:
        guard monthSymbols.count > row else { return nil }
        return monthSymbols[row]
      case Components.year.rawValue:
        let components = calendar.dateComponents([.year], from: minimumDate)
        guard let year = components.year else { return nil }
        return String(format: "%ld", year + row)
      default:
        return nil
      }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      let monthIndex = pickerView.selectedRow(inComponent: Components.month.rawValue)
      let yearIndex = pickerView.selectedRow(inComponent: Components.year.rawValue)
      coordinator.base.date = makeDate(from: monthIndex, and: yearIndex)
    }

    private func makeDate(from selectedMonthIndex: Int, and selectedYearIndex: Int) -> Date? {
      guard let baseYear = calendar.dateComponents([.year], from: minimumDate).year else {
        return nil
      }

      var dateComponents = DateComponents()
      dateComponents.month = selectedMonthIndex + 1
      dateComponents.year = selectedYearIndex + baseYear
      return calendar.date(from: dateComponents)
    }

    func setDate(_ date: Date) {
      guard let monthIndex = calendar.dateComponents([.month], from: date).month else { return }
      selectRow(monthIndex - 1, inComponent: Components.month.rawValue, animated: true)

      guard let baseYear = calendar.dateComponents([.year], from: minimumDate).year,
        let currentYear = calendar.dateComponents([.year], from: date).year
      else { return }
      selectRow(currentYear - baseYear, inComponent: Components.year.rawValue, animated: true)
    }
  }
#endif
