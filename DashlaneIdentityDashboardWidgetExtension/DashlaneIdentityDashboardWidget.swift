import SwiftUI
import UIDelight
import WidgetKit

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> PasswordHealthEntry {
    PasswordHealthEntry(
      score: 88, credentialCount: 28, compromisedCount: 1, reusedCount: 8, weakCount: 9)
  }

  func getSnapshot(in context: Context, completion: @escaping (PasswordHealthEntry) -> Void) {
    if context.isPreview {
      completion(placeholder(in: context))
    } else {
      completion(getLatestEntry())
    }
  }

  func getTimeline(
    in context: Context, completion: @escaping (Timeline<PasswordHealthEntry>) -> Void
  ) {
    let timeline = Timeline(entries: [getLatestEntry()], policy: .never)
    completion(timeline)
  }

  func getLatestEntry() -> PasswordHealthEntry {
    guard let userDefaults = UserDefaults(suiteName: "group.dashlane.sharedContainer") else {
      fatalError("Impossible to get the URL")
    }

    let score = userDefaults.integer(forKey: DashlaneWidgetConstant.score)
    let credentialCount = userDefaults.integer(forKey: DashlaneWidgetConstant.credentialCount)
    let compromisedCount = userDefaults.integer(forKey: DashlaneWidgetConstant.compromisedCount)
    let reusedCount = userDefaults.integer(forKey: DashlaneWidgetConstant.reusedCount)
    let weakCount = userDefaults.integer(forKey: DashlaneWidgetConstant.weakCount)

    return PasswordHealthEntry(
      score: score, credentialCount: credentialCount,
      compromisedCount: compromisedCount, reusedCount: reusedCount,
      weakCount: weakCount)
  }
}

struct DashlaneWidgetEntryView: View {
  @Environment(\.widgetFamily) var size
  var entry: Provider.Entry

  var body: some View {
    entries()
      .containerBackground(for: .widget) {
        WidgetAsset.widgetBackground.swiftUIColor
      }
  }

  #if targetEnvironment(macCatalyst)
    @ViewBuilder
    func entries() -> some View {
      switch size {
      case .systemSmall:
        SmallWidgetView(entry: entry)
      case .systemMedium:
        MediumWidgetView(entry: entry)
      default:
        SmallWidgetView(entry: entry)
      }
    }

  #else

    @ViewBuilder
    func entries() -> some View {
      switch size {
      case .accessoryCircular:
        CircularWidgetView(entry: entry)
      case .accessoryRectangular:
        RectangularWidgetView(entry: entry)
      case .accessoryInline:
        InlineWidgetView(entry: entry)
      case .systemSmall:
        SmallWidgetView(entry: entry)
      case .systemMedium:
        MediumWidgetView(entry: entry)
      default:
        SmallWidgetView(entry: entry)
      }
    }
  #endif
}

struct SmallWidgetView: View {
  var entry: Provider.Entry

  var body: some View {
    ScoreWidgetEntryView(entry: entry)
  }
}

struct MediumWidgetView: View {
  var entry: Provider.Entry

  var body: some View {
    HStack {
      ScoreWidgetEntryView(entry: entry)
      ScoreDetailWidgetEntryView(entry: entry)
    }
  }
}

#if !targetEnvironment(macCatalyst)
  struct GaugeScoreView: View {
    let value: Float
    let percentage: Int

    var body: some View {
      Gauge(value: value) {
        Text("\(percentage)")
      } currentValueLabel: {
        Image(uiImage: WidgetAsset.passwordHealthScore.image)
      }
      .gaugeStyle(.accessoryCircular)
    }
  }

  struct CircularWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
      GaugeScoreView(value: entry.gaugeValue, percentage: entry.percentage)
    }
  }

  struct RectangularWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
      HStack {
        GaugeScoreView(value: entry.gaugeValue, percentage: entry.percentage)

        Text(L10n.Localizable.widgetTitle)
          .font(.headline)
      }
    }
  }

  struct InlineWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
      Text(Image(uiImage: WidgetAsset.passwordHealthScore.image)) + Text(" \(entry.percentage)%")
    }
  }
#endif

@main
struct DashlaneWidget: Widget {
  let kind: String = DashlaneWidgetConstant.kind

  var supportedFamilies: [WidgetFamily] {
    #if targetEnvironment(macCatalyst)
      return [
        .systemSmall,
        .systemMedium,
      ]
    #else
      return [
        .systemSmall,
        .systemMedium,
        .accessoryCircular,
        .accessoryRectangular,
        .accessoryInline,
      ]
    #endif
  }

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      DashlaneWidgetEntryView(entry: entry)
    }
    .configurationDisplayName(L10n.Localizable.widgetDisplayName)
    .supportedFamilies(supportedFamilies)
    .description(L10n.Localizable.widgetDescription)
  }
}

struct DashlaneWidget_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(addDefaultBackground: false) {
      DashlaneWidgetEntryView(entry: PasswordHealthEntry())
        .previewContext(WidgetPreviewContext(family: .systemSmall))

      DashlaneWidgetEntryView(entry: PasswordHealthEntry(score: 78))
        .previewContext(WidgetPreviewContext(family: .systemSmall))

      DashlaneWidgetEntryView(
        entry: PasswordHealthEntry(
          score: 45, credentialCount: 100, compromisedCount: 20, reusedCount: 15, weakCount: 9)
      )
      .previewContext(WidgetPreviewContext(family: .systemMedium))

      DashlaneWidgetEntryView(entry: PasswordHealthEntry(score: 78))
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))

      DashlaneWidgetEntryView(entry: PasswordHealthEntry(score: 78))
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))

      DashlaneWidgetEntryView(entry: PasswordHealthEntry(score: 78))
        .previewContext(WidgetPreviewContext(family: .accessoryInline))
    }
  }
}
