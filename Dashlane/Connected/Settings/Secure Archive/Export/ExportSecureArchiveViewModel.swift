import Foundation
import CoreSession
import CorePersonalData
import DashlaneAppKit
import UIDelight
import CoreUserTracking
import SwiftTreats
import DashTypes

final class ExportSecureArchiveViewModel: ObservableObject, SessionServicesInjecting {

    enum State {
        case main
        case inProgress
    }

    let session: Session
    let databaseDriver: DatabaseDriver
    let reporter: ActivityReporterProtocol

    @Published
    var state = State.main

    @Published
    var passwordInput: String = ""

    @Published
    var displayInputError = false

    @Published
    var activityItem: ActivityItem?

    @Published
    var exportedArchiveURL: URL?

        init(session: Session, databaseDriver: DatabaseDriver, reporter: ActivityReporterProtocol) {
        self.session = session
        self.databaseDriver = databaseDriver
        self.reporter = reporter
    }

        private var isPasswordValid: Bool {
        guard let currentPassword = session.authenticationMethod.userMasterPassword else {
            return true 
        }
        return currentPassword == passwordInput
    }

    func export() {
        if isPasswordValid {
            state = .inProgress

            Task.detached(priority: .utility) { [weak self] in
                guard let self = self else { return }

                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Dashlane Secure Archive.dash")
                let exportURL = try self.databaseDriver.exportSecureArchive(usingPassword: self.passwordInput, to: fileURL)

                await MainActor.run {
                    if Device.isMac {
                        self.exportedArchiveURL = exportURL
                    } else {
                        self.activityItem = ActivityItem(items: exportURL)
                    }
                }

                self.reporter.report(UserEvent.ExportData(backupFileType: .secureVault))
            }
        } else {
            displayInputError = true
        }
    }

    static var mock: ExportSecureArchiveViewModel {
        return ExportSecureArchiveViewModel(session: Session.mock,
                                            databaseDriver: InMemoryDatabaseDriver(),
                                            reporter: .fake)
    }
}
