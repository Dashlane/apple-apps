#if canImport(UIKit)
  import CoreLocalization
  import SwiftUI
  import SwiftTreats

  public struct DatePickerView: View {
    @Binding
    var date: Date?

    @State
    var presented = false

    @Environment(\.isEnabled)
    var isEnabled

    let dateFormatter: DateFormatter
    let maximumDate: Date?
    let minimumDate: Date?
    let mode: FiberDatePickerMode

    public init(
      _ date: Binding<Date?>,
      dateFormatter: DateFormatter,
      mode: FiberDatePickerMode,
      maximumDate: Date? = nil,
      minimumDate: Date? = nil
    ) {
      self._date = date
      self.dateFormatter = dateFormatter
      self.mode = mode
      self.maximumDate = maximumDate
      self.minimumDate = minimumDate
    }

    public var body: some View {
      if Device.isMac {
        textualPickerView
          .accessibilityLabel(accessibilityLabelTextualPicker)
      } else {
        FiberKeyboardDatePicker(
          $date,
          isPresented: $presented,
          dateFormatter: dateFormatter,
          mode: mode,
          maximumDate: maximumDate,
          minimumDate: minimumDate
        )
        .accessibilityLabel(accessibilityLabelInlinePicker)
      }
    }

    @ViewBuilder
    private var textualPickerView: some View {
      ZStack {
        HStack {
          if let date = date {
            Text(dateFormatter.string(from: date))
          } else {
            Text("")
          }
          Spacer()
        }

      }
      .frame(maxWidth: .infinity)
      .contentShape(Rectangle())
      .fullScreenCover(isPresented: $presented) {
        modalPickerView
      }
      .onTapGesture {
        self.presented = true
      }
    }

    @ViewBuilder
    private var modalPickerView: some View {
      ZStack {
        VStack(spacing: 0) {
          HStack {
            Spacer()
            Button(
              action: { self.presented = false },
              label: {
                Text(L10n.Core.kwDoneButton).bold()
              })
          }
          .padding([.top, .trailing])
          FiberInlineDatePicker(
            $date,
            isPresented: $presented,
            dateFormatter: dateFormatter,
            mode: mode,
            maximumDate: maximumDate,
            minimumDate: minimumDate)
        }
        .frame(width: 320)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 10)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  extension DatePickerView {
    var accessibilityLabelTextualPicker: String {
      guard isEnabled else {
        return ""
      }
      return presented ? L10n.Core.accessibilityPresented : L10n.Core.accessibilityHidden
    }

    var accessibilityLabelInlinePicker: String {
      guard isEnabled else {
        return ""
      }
      return presented ? L10n.Core.accessibilityExpanded : L10n.Core.accessibilityCollapsed
    }

    var presentedAccessibilityLabel: String {
      Device.isMac ? L10n.Core.accessibilityPresented : L10n.Core.accessibilityExpanded
    }

    var notPresentedAccessibilityLabel: String {
      Device.isMac ? L10n.Core.accessibilityHidden : L10n.Core.accessibilityCollapsed
    }
  }

  struct DatePickerView_Previews: PreviewProvider {
    static let date = Date()
    static var previews: some View {
      DatePickerView(
        .constant(date),
        dateFormatter: .birthDateFormatter,
        mode: .monthAndYear)
    }
  }
#endif
