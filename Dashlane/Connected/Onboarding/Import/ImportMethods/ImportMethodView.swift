import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct ImportMethodView<Model: ImportMethodViewModelProtocol>: View {
  @ObservedObject
  var viewModel: Model

  var body: some View {
    List {
      ForEach(viewModel.sections) { section in
        Section(
          section.header ?? ""
        ) {
          ForEach(section.items) { method in
            ImportMethodItemView(importMethod: method)
              .padding(.vertical, 13.0)
              .contentShape(Rectangle())
              .onTapWithFeedback {
                self.viewModel.methodSelected(method)
              }
          }
        }
      }
    }
    .listStyle(.ds.insetGrouped)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(CoreL10n.kwBack, action: viewModel.back)
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button(CoreL10n.kwSkip, action: viewModel.skip)
      }
    }
    .navigationTitle(CoreL10n.m2WImportGenericImportScreenHeader)
    .reportPageAppearance(.import)
    .onAppear {
      viewModel.logDisplay()
    }
  }
}

struct ImportMethodView_Previews: PreviewProvider {

  class FakeModel: ImportMethodViewModelProtocol {
    var shouldShowDWMScanPrompt: Bool
    var shouldShowDWMScanResult: Bool
    var sections: [ImportMethodSection]
    var completion: (ImportMethodCompletion) -> Void

    init(
      importService: ImportMethodServiceProtocol, shouldShowDWMScanPrompt: Bool = false,
      shouldShowDWMScanResult: Bool = false
    ) {
      self.shouldShowDWMScanPrompt = shouldShowDWMScanPrompt
      self.shouldShowDWMScanResult = shouldShowDWMScanResult
      sections = importService.methods
      completion = { _ in }
    }

    func logDisplay() {}
    func dismissLastChanceScanPrompt() {}
    func startDWMScan() {}
    func methodSelected(_ method: LegacyImportMethod) {}
    func back() {}
    func skip() {}
  }

  static var previews: some View {
    MultiContextPreview {
      Group {
        NavigationView {
          ImportMethodView(
            viewModel: FakeModel(importService: ImportMethodService.mock(for: .firstPassword)))
        }
        .previewDisplayName("First password")

        NavigationView {
          ImportMethodView(
            viewModel: FakeModel(importService: ImportMethodService.mock(for: .browser)))
        }
        .previewDisplayName("Browser")

        NavigationView {
          ImportMethodView(
            viewModel: FakeModel(
              importService: ImportMethodService.mock(for: .firstPassword),
              shouldShowDWMScanPrompt: true))
        }
        .previewDisplayName("First password, shows prompt")

        NavigationView {
          ImportMethodView(
            viewModel: FakeModel(
              importService: ImportMethodService.mock(for: .firstPassword),
              shouldShowDWMScanResult: true))
        }
        .previewDisplayName("First password, shows result")
      }
    }
  }
}
