import SwiftUI
import CoreSession
import CorePersonalData
import DashlaneAppKit
import CoreUserTracking
import DesignSystem

struct SecureArchiveSectionContent: View {

    let exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory

    @State
    private var showExportView = false

    var body: some View {
        Button(action: { showExportView = true }, label: {
            Text("Export")
                .foregroundColor(.ds.text.neutral.standard)
                .textStyle(.body.standard.regular)
        })
        .sheet(isPresented: $showExportView) {
            ExportSecureArchiveView(viewModel: exportSecureArchiveViewModelFactory.make())
        }
    }
}

struct SecureArchiveSectionContent_Previews: PreviewProvider {
    static var previews: some View {
        SecureArchiveSectionContent(exportSecureArchiveViewModelFactory: .init({ .mock }))
    }
}
