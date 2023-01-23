import SwiftUI
import UIDelight
import VaultKit
import CoreSharing

struct ShareFlowView: View {
    @StateObject
    var model: ShareFlowViewModel

    @Environment(\.dismiss)
    var dismiss

    init(model: @autoclosure @escaping () -> ShareFlowViewModel) {
        _model = .init(wrappedValue: model())
    }

    var body: some View {
        StepBasedNavigationView(steps: $model.composeSteps) { composeStep in
            switch composeStep {
            case .items:
                ShareItemsSelectionView(model: model.makeItemsViewModel())
            case .recipients:
                if model.state == .composing {
                    ShareRecipientsSelectionView(isRoot: model.composeSteps.count == 1, model: model.makeRecipientsViewModel())
                } else {
                    sendingView
                }
            }
        }
        .alert(model.errorMessage, isPresented: $model.showError) { }
        .animation(.easeInOut, value: model.state)
    }

    var sendingView: some View {
        SendingShareView(step: model.state == .success ? .success : .inProgress)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if model.state == .success {
                        Button(L10n.Localizable.kwButtonClose) {
                            dismiss()
                        }
                    }
                }
            }
    }
}

 struct ShareFlowView_Previews: PreviewProvider {
     static let sharingService = SharingServiceMock(pendingUserGroups: [],
                                                    pendingItemGroups: [],
                                                    sharingUserGroups: [SharingItemsUserGroup(id: "group", name: "A simple group", isMember: true, items: [.mock(id: "1"), .mock(id: "2")], users: [.mock(), .mock(), .mock()])
                                                                       ],
                                                    sharingUsers: [SharingItemsUser(id: "_", items: [.mock(id: "3")])],
                                                    pendingItems: [:])

     struct TestingSheet<Sheet: View>: View {
         @State
         var isPresented: Bool = false

         @ViewBuilder
         let sheet: () -> Sheet

         var body: some View {
             Button("Show") {
                 isPresented = true
             }
             .sheet(isPresented: $isPresented) {
                 sheet()
             }
         }
     }

     static var previews: some View {
         TestingSheet {
             ShareFlowView(model: .mock(sharingService: sharingService))
         }.previewDisplayName("Full Flow")

         TestingSheet {
             ShareFlowView(model: .mock(items: [PersonalDataMock.Credentials.amazon],
                                        sharingService: sharingService))
         }.previewDisplayName("Flow one item")
     }
 }
