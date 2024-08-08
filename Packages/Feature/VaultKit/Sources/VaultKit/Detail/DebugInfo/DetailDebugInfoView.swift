import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight

struct DetailDebugInfoView: View {

  private let item: VaultItem

  @Environment(\.toast)
  var toast

  @Binding
  private var isDebugInfoShown: Bool

  @State
  var screenshotShareActivityItem: ActivityItem?

  @State
  var reveal: Bool = false

  @State
  private var debugInfoText: String = ""

  static var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return formatter
  }()

  init(item: VaultItem, isDebugInfoShown: Binding<Bool>) {
    self.item = item
    self._isDebugInfoShown = isDebugInfoShown
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        buttons

        debugInfo

        Spacer()
      }
      .padding()
      .navigationTitle(L10n.Core.debugInfoTitle)
      .navigationBarTitleDisplayMode(.inline)
      .interactiveDismissDisabled()
      .toolbar {
        Button(CoreLocalization.L10n.Core.kwButtonClose) {
          isDebugInfoShown = false
        }
        .foregroundColor(.ds.text.brand.standard)
      }
      .onPreferenceChange(DebugInfoPreferenceKey.self) { value in
        debugInfoText = value
      }
    }
  }

  @MainActor @ViewBuilder
  private var buttons: some View {
    Section {
      VStack {
        Button(L10n.Core.debugInfoCopyAllInformation) {
          copyDebugInfoToClipboard()
          toast(L10n.Core.kwCopied, image: .ds.feedback.success.outlined)
        }

        Button(L10n.Core.debugInfoTakeAScreenshot) {
          takeScreenshot()
        }
        .activitySheet($screenshotShareActivityItem)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .quiet)
    }
  }

  @ViewBuilder
  var debugInfo: some View {
    VStack {
      DebugField(label: "id", value: item.id.rawValue)
      DebugField(label: "metadata.contentType", value: item.metadata.contentType.rawValue)
      DebugField(label: "metadata.syncStatus", value: item.metadata.syncStatus?.rawValue ?? "nil")
      DebugField(
        label: "metadata.lastSyncTimestamp",
        value: String(item.metadata.lastSyncTimestamp?.rawValue ?? 0))
      DebugField(label: "isShared", value: item.isShared ? "true" : "false")
      DebugField(
        label: "metadata.sharingPermission",
        value: item.metadata.sharingPermission?.rawValue ?? "nil")
      DebugField(label: "creationDatetime", value: item.creationDatetime.formattedString)
      DebugField(
        label: "userModificationDatetime", value: item.userModificationDatetime.formattedString)
      DebugField(label: "hasAttachments", value: item.hasAttachments ? "true" : "false")

      switch item.enumerated {
      case let .credential(credential):
        DebugField(
          label: "otpURL",
          value: reveal
            ? credential.otpURL?.absoluteString ?? "nil" : credential.obfuscatedOTPSecret)
      case let .drivingLicence(drivingLicense):
        DebugField(
          label: "expireDate",
          value: CalendarDateFormatted.string(from: drivingLicense.expireDate) ?? "nil")
        DebugField(
          label: "deliveryDate",
          value: CalendarDateFormatted.string(from: drivingLicense.deliveryDate) ?? "nil")
      case let .passport(passport):
        DebugField(
          label: "expireDate",
          value: CalendarDateFormatted.string(from: passport.expireDate) ?? "nil")
        DebugField(
          label: "deliveryDate",
          value: CalendarDateFormatted.string(from: passport.deliveryDate) ?? "nil")
      case let .idCard(idCard):
        DebugField(
          label: "expireDate", value: CalendarDateFormatted.string(from: idCard.expireDate) ?? "nil"
        )
        DebugField(
          label: "deliveryDate",
          value: CalendarDateFormatted.string(from: idCard.deliveryDate) ?? "nil")
      case let .creditCard(creditCard):
        DebugField(label: "expiryDate", value: creditCard.expiryDate.formattedString)
        DebugField(label: "issuingDate", value: creditCard.issuingDate.formattedString)
      default:
        EmptyView()
      }
    }
    .padding(.vertical)
    .onTapGesture {
      revealProtectedData()
    }
  }

  @MainActor
  private func takeScreenshot() {
    let renderer = ImageRenderer(content: debugInfo.frame(width: 430))
    renderer.scale = 2
    if let uiImage = renderer.uiImage {
      screenshotShareActivityItem = ActivityItem(items: uiImage)
    }
  }

  func revealProtectedData() {
    reveal.toggle()
  }

  func copyDebugInfoToClipboard() {
    UIPasteboard.general.string = debugInfoText
  }

}

struct DebugField: View {
  let label: String
  let value: String

  var body: some View {
    VStack {
      Text("\(label): \(value)")
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.ds.text.neutral.quiet)
        .textSelection(.enabled)
        .preference(key: DebugInfoPreferenceKey.self, value: "\(label): \(value)\n")
      Divider()
    }
  }
}

struct DebugInfoPreferenceKey: PreferenceKey {
  static var defaultValue: String = ""

  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}

extension Credential {
  fileprivate var obfuscatedOTPSecret: String {
    if let otpString = self.otpURL?.absoluteString {
      if let range = otpString.range(of: "secret=") {
        let secret = otpString[range.upperBound...]
        return "\(otpString[..<range.upperBound])\(String(repeating: "•", count: secret.count))"
      }
      return otpString
    }
    return "nil"
  }
}

extension Date? {
  fileprivate var formattedString: String {
    if let originalDate = self {
      return DetailDebugInfoView.formatter.string(from: originalDate)
    } else {
      return "nil"
    }
  }
}

struct DetailDebugInfoView_Previews: PreviewProvider {
  static var previews: some View {
    DetailDebugInfoView(item: .mockSynced(creationDate: .now), isDebugInfoShown: .constant(false))
  }
}
