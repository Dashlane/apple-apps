import CoreLocalization
import CoreSession
import CoreTypes
import SwiftUI
import UIDelight

struct DebugAccountList: View {
  @StateObject
  var viewModel: DebugAccountListViewModel

  let didSelectLogin: (Login) -> Void

  init(
    viewModel: @autoclosure @escaping () -> DebugAccountListViewModel,
    didSelectLogin: @escaping (Login) -> Void
  ) {
    self._viewModel = .init(wrappedValue: viewModel())
    self.didSelectLogin = didSelectLogin
  }

  @Environment(\.dismiss)
  private var dismiss

  var body: some View {
    List {
      if !viewModel.localAccounts.isEmpty {
        Section("Local accounts") {
          ForEach(viewModel.localAccounts, id: \.email) { localAccount in
            makeRow(for: localAccount)
          }
          .onDelete(perform: deleteRow(at:))
        }
      }

      Section("Other accounts") {
        ForEach(viewModel.testAccounts, id: \.email) { localAccount in
          makeRow(for: localAccount)
        }
      }
    }
    .onAppear {
      self.viewModel.fetchLocalAccounts()
    }
    .overlay(alignment: .topTrailing) {
      Button(action: dismiss.callAsFunction) {
        Image(systemName: "xmark.circle")
          .resizable()
          .frame(width: 20, height: 20)
      }
      .padding(.trailing, 20)
      .padding(.top, 10)
    }
    .presentationDetents([.medium, .large])
  }

  private func deleteRow(at indexSet: IndexSet) {
    let items = indexSet.map {
      viewModel.localAccounts[$0]
    }
    guard let email = items.first?.email else {
      return
    }
    viewModel.removeLocalData(for: .init(email))
  }

  @ViewBuilder
  private func makeRow(for accountInfo: AccountInfo) -> some View {
    DebugAccountRow(accountInfo: accountInfo)
      .onTapWithFeedback {
        UserFeedbackGenerator.makeImpactGenerator().impactOccurred()
        self.didSelectLogin(.init(accountInfo.email))
      }
  }
}
