import AuthenticatorKit
import CoreLocalization
import DashTypes
import DesignSystem
import PDFKit
import SwiftUI
import UIComponents
import UIDelight

struct SunsetView: View {

  @State
  private var isLearnMoreDisplayed: Bool = false

  let cardContent = [
    CoreLocalization.L10n.Core.authenticatorSunsetExportStep1,
    CoreLocalization.L10n.Core.authenticatorSunsetExportStep2,
    CoreLocalization.L10n.Core.authenticatorSunsetExportStep3,
  ]

  @StateObject
  var model: SunsetViewModel

  init(model: @autoclosure @escaping () -> SunsetViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    VStack(alignment: .leading) {
      ScrollView {
        VStack(alignment: .leading, spacing: 48) {
          header
            .padding(.trailing)
          InstructionsCardView(cardContent: cardContent)
        }
      }
      Spacer()
      buttons
        .padding(.bottom)
    }
    .padding(.horizontal, 24)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .safariSheet(isPresented: $isLearnMoreDisplayed, url: UserSupportURL.helpCenter.url)
    .task {
      model.makePDF()
    }

  }

  var header: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(CoreLocalization.L10n.Core.authenticatorSunsetExportTitle)
        .font(.authenticator(.largeTitle))
        .foregroundColor(.ds.text.neutral.catchy)
      Text(CoreLocalization.L10n.Core.authenticatorSunsetExportMessage)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)

    }
  }

  var buttons: some View {
    VStack(spacing: 24) {
      shareLink

      Button(
        action: { isLearnMoreDisplayed.toggle() },
        label: {
          Text(CoreLocalization.L10n.Core.authenticatorSunsetExportLearnMore)
            .frame(maxWidth: .infinity)
        }
      )
      .style(mood: .brand, intensity: .supershy)
    }
  }

  @ViewBuilder
  var shareLink: some View {
    if let pdf = model.pdfDocument {
      ShareLink(
        item: pdf,
        subject: Text("2FA Tokens"),
        preview:
          SharePreview("2FA Tokens", image: model.tokens.makeImage()),
        label: {
          Text(CoreLocalization.L10n.Core.authenticatorSunsetExportAction)
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundColor(.ds.text.inverse.standard)
            .background(.ds.container.expressive.brand.catchy.idle)
            .cornerRadius(10)
        })
    } else {
      ProgressView()
    }
  }
}

#Preview("SunsetView") {
  MultiContextPreview(dynamicTypePreview: true) {
    SunsetView(model: SunsetViewModel(databaseService: AuthenticatorDatabaseServiceMock()))
  }
}

extension PDFDocument: Transferable {
  public static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(contentType: .pdf) { pdf in
      return pdf.dataRepresentation() ?? Data()
    } importing: { data in
      return PDFDocument(data: data) ?? PDFDocument()
    }
    DataRepresentation(exportedContentType: .pdf) { pdf in
      return pdf.dataRepresentation() ?? Data()
    }
  }
}
