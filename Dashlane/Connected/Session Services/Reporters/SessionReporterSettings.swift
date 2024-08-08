import CoreSettings
import Foundation

enum ReporterSettingsKey: String, CaseIterable, LocalSettingsKey {
  case lastStateReportDate

  var type: Any.Type {
    Date.self
  }
}

typealias ReporterSettings = KeyedSettings<ReporterSettingsKey>
