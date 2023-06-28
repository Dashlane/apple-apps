#if os(iOS)
import SwiftUI
import UIComponents
import SwiftTreats

public enum DateRange {
    case future
    case past
    case closed(start: Date, end: Date)
    case from(_ date: Date)
    case to(_ date: Date)

    var minimumDate: Date? {
        switch self {
        case .future:
            return Date()
        case let .closed(startDate, _), let .from(startDate):
            return startDate
        default:
            return nil
        }
    }

    var maximumDate: Date? {
        switch self {
        case .past:
            return Date()
        case let .closed(_, endDate), let .to(endDate):
            return endDate
        default:
            return nil
        }
    }
}

public struct DateDetailField: DetailField {
    public let title: String

    @Binding
    var date: Date?

    var formatter: DateFormatter

    @Environment(\.detailMode)
    var detailMode

    let range: DateRange
    let mode: FiberDatePickerMode

    public init(
        title: String,
        date: Binding<Date?>,
        formatter: DateFormatter = DateFormatter.birthDateFormatter,
        range: DateRange,
        mode: FiberDatePickerMode = .default
    ) {
        self.title = title
        self._date = date
        self.range = range
        self.mode = mode
        self.formatter = formatter
    }

    public var body: some View {
        ZStack {
            datePicker.modifier(FocusingOnTapModifier())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.easeOut, value: date)
    }

    private var datePicker: some View {
        DatePickerView($date,
                       dateFormatter: formatter,
                       mode: mode,
                       maximumDate: range.maximumDate,
                       minimumDate: range.minimumDate)
            .labeled(title)
            .contentShape(Rectangle())
            .disabled(!detailMode.isEditing)
    }
}

struct DateDetailField_Previews: PreviewProvider {

    static let date = Date()
    static var previews: some View {
        Form {
            DateDetailField(title: "Date",
                            date: .constant(date),
                            range: .future,
                            mode: .default)
        }
    }
}

private struct FocusingOnTapModifier: ViewModifier {
    @FocusState
    var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .onTapGesture {
                isFocused = true
            }
    }
}
#endif
