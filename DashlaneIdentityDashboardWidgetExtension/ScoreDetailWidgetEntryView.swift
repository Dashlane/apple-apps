import SwiftUI
import UIDelight
import WidgetKit

private struct ScoreRow: View {
  var title: String
  var score: Int?
  var color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      VStack {
        Spacer()
        Text(title.uppercased())
          .font(.system(size: 10))
          .foregroundStyle(.gray)
          .fontWeight(.bold)
          .minimumScaleFactor(0.4)
          .lineLimit(1)
      }
      Text(displayScore)
        .font(.body)
        .foregroundStyle(color)
        .fontWeight(.heavy)
        .widgetAccentable()
    }
  }

  private var displayScore: String {
    guard let score = self.score else { return " - - " }
    return String(score)
  }
}

struct ScoreDetailWidgetEntryView: View {
  var entry: PasswordHealthEntry

  var body: some View {
    LazyVGrid(
      columns: Array(repeating: .init(.flexible(), spacing: 0, alignment: .leading), count: 2),
      alignment: .leading, spacing: 10
    ) {
      ScoreRow(
        title: L10n.Localizable.kwPurchaseTotal, score: entry.credentialCount, color: .primary)
      ScoreRow(
        title: L10n.Localizable.passwordHealthModuleCompromised, score: entry.compromisedCount,
        color: .red)
      ScoreRow(
        title: L10n.Localizable.passwordHealthModuleReused, score: entry.reusedCount, color: .orange
      )
      ScoreRow(
        title: L10n.Localizable.passwordHealthModuleWeak, score: entry.weakCount, color: .orange)

    }
  }
}

struct ScoreDetailWidgetEntryView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(addDefaultBackground: false) {
      DashlaneWidgetEntryView(
        entry: PasswordHealthEntry(
          score: 45, credentialCount: 100, compromisedCount: 20, reusedCount: 15, weakCount: 9)
      )
      .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }
}
