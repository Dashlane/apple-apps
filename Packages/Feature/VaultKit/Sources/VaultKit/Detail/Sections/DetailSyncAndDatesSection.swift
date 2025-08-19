import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI

struct DetailSyncAndDatesSection: View {
  let item: VaultItem

  private var updateDateLabel: String {
    return item.isShared
      ? CoreL10n.vaultItemModificationDateByYouLabel : CoreL10n.vaultItemModificationDateLabel
  }

  var body: some View {
    Section {
      if let creationDate = item.creationDatetime {
        let text =
          if item.isCreation, item.metadata.syncStatus == .pendingUpload {
            CoreL10n.vaultItemSyncStatusPendingUpload
          } else {
            creationDate.formatted(.timeAgo)
          }

        DisplayField(CoreL10n.vaultItemCreationDateLabel, text: text)
      }

      if !item.isCreation, let modificationDate = item.userModificationDatetime {
        let text =
          if item.metadata.syncStatus == .pendingUpload {
            CoreL10n.vaultItemSyncStatusPendingUpload
          } else {
            modificationDate.formatted(.timeAgo)
          }

        DisplayField(updateDateLabel, text: text)
      }

      if let lastUsed = item.metadata.lastLocalUseDate {
        DisplayField(updateDateLabel, text: lastUsed.formatted(.timeAgo))
      }
    }
  }

}

extension VaultItem {
  fileprivate var isCreation: Bool {
    return userModificationDatetime == nil || userModificationDatetime == creationDatetime
  }
}

private struct CustomTimeAgoFormatter: FormatStyle {
  private static let timestampFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .named
    formatter.unitsStyle = .full
    return formatter
  }()

  func format(_ date: Date) -> String {
    if abs(date.timeIntervalSinceNow) < 60 {
      return CoreL10n.securityAlertUnresolvedJustnow
    }
    return Self.timestampFormatter.localizedString(for: date, relativeTo: Date())
  }
}

extension FormatStyle where Self == CustomTimeAgoFormatter {
  static var timeAgo: CustomTimeAgoFormatter {
    .init()
  }
}

extension VaultItem where Self == Credential {
  static func mockPendingSync(creationDate: Date, modificationDate: Date? = nil) -> Credential {
    var pendingSync = Credential(login: "", password: "", syncStatus: .pendingUpload)
    pendingSync.creationDatetime = creationDate
    pendingSync.userModificationDatetime = modificationDate
    return pendingSync
  }

  static func mockSynced(creationDate: Date, modificationDate: Date? = nil) -> Credential {
    var synced = Credential(login: "", password: "", syncStatus: nil)
    synced.creationDatetime = creationDate
    synced.userModificationDatetime = modificationDate
    return synced
  }
}

struct SyncAndDatesSection_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      pendingSyncPreviews
      syncedPreviews
    }
    .listStyle(.ds.insetGrouped)
  }

  @ViewBuilder
  static var pendingSyncPreviews: some View {
    List {
      DetailSyncAndDatesSection(item: .mockPendingSync(creationDate: .now.substract(days: 2)))
    }.previewDisplayName("Created and sync pending")

    List {
      DetailSyncAndDatesSection(
        item: .mockPendingSync(creationDate: .now.substract(days: 2), modificationDate: .now))
    }.previewDisplayName("Updated and sync pending")
  }

  @ViewBuilder
  static var syncedPreviews: some View {
    List {
      DetailSyncAndDatesSection(item: .mockSynced(creationDate: .now.substract(days: 2)))
    }.previewDisplayName("Created and synced")

    List {
      DetailSyncAndDatesSection(item: .mockSynced(creationDate: .now))
    }.previewDisplayName("Created just now and synced")

    List {
      DetailSyncAndDatesSection(
        item: .mockSynced(
          creationDate: .now.substract(days: 2), modificationDate: .now.substract(days: 1)))
    }
    .previewDisplayName("Updated and synced")

    List {
      DetailSyncAndDatesSection(
        item: .mockSynced(creationDate: .now.substract(days: 2), modificationDate: .now))
    }
    .previewDisplayName("Updated now and synced")
  }
}
