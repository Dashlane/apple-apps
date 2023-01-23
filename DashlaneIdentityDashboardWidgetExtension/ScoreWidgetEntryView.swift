import SwiftUI
import WidgetKit

struct ScoreWidgetEntryView: View {
    var entry: PasswordHealthEntry

    var body: some View {
        VStack {
            Text(L10n.Localizable.widgetTitle.uppercased())
                .font(.system(size: 10))
                .foregroundColor(Color.gray)
                .fontWeight(.bold)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            ZStack {
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                    .rotation(.degrees(135))
                    .foregroundColor(Color(UIColor.lightGray).opacity(0.3))
                progressCircle
                progressTitle
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    var progressCircle: some View {
        Circle()
            .trim(from: 0.0, to: CGFloat(entry.progress))
            .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
            .rotation(.degrees(135))
            .foregroundColor(progressColor)
    }
    
    @ViewBuilder
    var progressTitle: some View {
        VStack {
            Text(displayScore ?? "- -").font(.system(size: 40)).fontWeight(.heavy)
            if displayScore != nil {
                Text(L10n.Localizable.widgetScoreSubtitle.uppercased())
                    .font(.system(size: 8))
            }
        }
    }
    
    private var displayScore: String? {
        guard let score = entry.score else { return nil }
        return String(score)
    }
    
    private var progressColor: Color {
        guard let score = entry.score else { return Color(UIColor.lightGray).opacity(0.3) }

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
        
        DashlaneWidgetEntryView(entry: PasswordHealthEntry(score: 78))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
