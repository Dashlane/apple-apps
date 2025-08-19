import SwiftUI
import WidgetKit

struct ScoreWidgetEntryView: View {
  var entry: PasswordHealthEntry

  var body: some View {
    VStack {
      Text(L10n.Localizable.widgetTitle.uppercased())
        .font(.system(size: 10))
        .foregroundStyle(.gray)
        .fontWeight(.bold)
        .minimumScaleFactor(0.4)
        .lineLimit(1)

      ZStack {
        gauge()
          .foregroundStyle(Color(UIColor.lightGray).opacity(0.3))

        gauge(to: CGFloat(entry.progress))
          .foregroundStyle(progressColor)
          .widgetAccentable()

        progressTitle

        progressSubtitle
          .frame(maxHeight: .infinity, alignment: .bottom)
          .padding(.bottom, 4)
      }
    }
  }

  @ViewBuilder
  private func gauge(to: CGFloat = 0.75) -> some View {
    Circle()
      .trim(from: 0.0, to: to)
      .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
      .rotation(.degrees(135))
      .padding(6)
  }

  @ViewBuilder
  private var progressTitle: some View {
    Text(displayScore ?? "--")
      .font(.system(size: 40, weight: .heavy))
      .monospacedDigit()
  }

  @ViewBuilder
  private var progressSubtitle: some View {
    if displayScore != nil {
      Text(L10n.Localizable.widgetScoreSubtitle.uppercased())
        .font(.system(size: 8))
    }
  }

  private var displayScore: String? {
    guard let score = entry.score else { return nil }
    return String(score)
  }

  private var progressColor: Color {
    guard let score = entry.score else { return .clear }

    if score <= 50 {
      return .red
    } else if score <= 70 {
      return .orange
    } else {
      return .green
    }
  }
}

struct ScoreWidgetEntryView_Previews: PreviewProvider {
  static var previews: some View {
    DashlaneWidgetEntryView(entry: PasswordHealthEntry())
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      .previewDisplayName("No Score")

    DashlaneWidgetEntryView(entry: PasswordHealthEntry(score: 15))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      .previewDisplayName("Bad Score")

    DashlaneWidgetEntryView(entry: PasswordHealthEntry(score: 55))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      .previewDisplayName("Okay Score")

    DashlaneWidgetEntryView(entry: PasswordHealthEntry(score: 78))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      .previewDisplayName("Good Score")
  }
}
