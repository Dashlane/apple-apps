import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct ImportMethodView<Model: ImportMethodViewModelProtocol>: View {
  @ObservedObject
  var viewModel: Model

  var body: some View {
    FullScreenScrollView {
      VStack(spacing: 8) {

        if viewModel.shouldShowDWMScanResult {
          darkWebMonitoringResults
            .padding()
        }

        if viewModel.shouldShowDWMScanPrompt {
          Infobox(
            L10n.Localizable.darkWebMonitoringOnboardingScanPromptTitle,
            description: L10n.Localizable.darkWebMonitoringOnboardingScanPromptDescription
          ) {
            Button(
              action: viewModel.startDWMScan,
              title: L10n.Localizable.darkWebMonitoringOnboardingScanPromptScan
            )
            Button(
              action: viewModel.dismissLastChanceScanPrompt,
              title: L10n.Localizable.darkWebMonitoringOnboardingScanPromptIgnore
            )
          }
          .padding(8)
          .padding()
        }

        Form {
          ForEach(viewModel.sections) { section in
            Section(
              header:
                Text(section.header ?? "")
                .padding(.top, 16)
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
      }
    }
    .backgroundColorIgnoringSafeArea(.ds.background.default)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        NavigationBarButton(CoreLocalization.L10n.Core.kwBack, action: viewModel.back)
      }
      ToolbarItem(placement: .topBarTrailing) {
        NavigationBarButton(CoreLocalization.L10n.Core.kwSkip, action: viewModel.skip)
      }
    }
    .navigationTitle(
      viewModel.shouldShowDWMScanResult
        ? L10n.Localizable.dwmOnboardingFixBreachesMainTitle
        : CoreLocalization.L10n.Core.m2WImportGenericImportScreenHeader
    )
    .reportPageAppearance(.import)
    .onAppear {
      viewModel.logDisplay()
    }
  }

  private var darkWebMonitoringResults: some View {
    HStack(alignment: .top, spacing: 10) {
      Image.ds.feedback.success.outlined
        .fiberAccessibilityHidden(true)
        .foregroundColor(.ds.text.positive.quiet)
      VStack(alignment: .leading, spacing: 10) {
        Text(L10n.Localizable.darkWebMonitoringOnboardingResultsNoBreachesTitle)
          .foregroundColor(.ds.text.positive.standard)
          .font(.headline)
          .fixedSize(horizontal: false, vertical: true)
        Text(L10n.Localizable.darkWebMonitoringOnboardingResultsNoBreachesBody)
          .foregroundColor(.ds.text.positive.standard)
          .font(.subheadline)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(Color.ds.container.expressive.positive.quiet.idle)
    .cornerRadius(4)
    .padding(.horizontal, 8)
    .padding(.top, 24)
    .fiberAccessibilityElement(children: .combine)
    .fiberAccessibilityLabel(
      Text(
        "\(CoreLocalization.L10n.Core.accessibilityInfoSection): \(L10n.Localizable.darkWebMonitoringOnboardingResultsNoBreachesTitle), \(L10n.Localizable.darkWebMonitoringOnboardingResultsNoBreachesBody)"
      ))
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
    func methodSelected(_ method: ImportMethod) {}
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
        NavigationView {
          ImportMethodView(
            viewModel: FakeModel(importService: ImportMethodService.mock(for: .browser)))
        }
        NavigationView {
          ImportMethodView(
            viewModel: FakeModel(
              importService: ImportMethodService.mock(for: .firstPassword),
              shouldShowDWMScanPrompt: true))
        }
        NavigationView {
          ImportMethodView(
            viewModel: FakeModel(
              importService: ImportMethodService.mock(for: .firstPassword),
              shouldShowDWMScanResult: true))
        }
      }
    }
  }
}
