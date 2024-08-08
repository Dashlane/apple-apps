import Foundation
import SwiftUI

#if canImport(UIKit)
  struct BottomSheetPreview: View {
    enum Sheet: Identifiable {
      var id: Self { self }
      case authenticator
      case verifyMasterPassword

      var title: String {
        switch self {
        case .authenticator:
          return "Secure your account with our Authenticator tool"
        case .verifyMasterPassword:
          return "Take a moment to verify your Master Password"
        }
      }

      var description: String {
        switch self {
        case .authenticator:
          return
            "Use Dashlane's Authenticator tool to add an extra laver of security to your accounts with 2-factor authentication (2FA)."
        case .verifyMasterPassword:
          return
            "Your Master Password is the key to your vault. If you forget it, you could get locked out of your account."
        }
      }
    }

    @State private var activeSheet: Sheet?

    var body: some View {
      NavigationStack {
        VStack {
          Button("Display Authenticator sheet") {
            activeSheet = .authenticator
          }
          Button("Display verify MP sheet") {
            activeSheet = .verifyMasterPassword
          }
        }
        .buttonStyle(.designSystem(.titleOnly))
        .style(intensity: .quiet)
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .sheet(item: $activeSheet) { activeSheet in
          BottomSheet(
            activeSheet.title,
            description: activeSheet.description,
            actions: {
              Button("Discard") {
                self.activeSheet = nil
              }
              .buttonStyle(.designSystem(.titleOnly))

              if activeSheet == .verifyMasterPassword {
                Button("More info") {
                  self.activeSheet = nil
                }
                .buttonStyle(.designSystem(.titleOnly))
                .style(intensity: .quiet)
              }
            },
            header: {
              switch activeSheet {
              case .authenticator:
                VStack {
                  Image(systemName: "lock.rectangle.stack.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundStyle(Color.ds.text.brand.standard.gradient)
                  Text("Header Area")
                    .textStyle(.title.section.medium)
                    .foregroundStyle(Color.ds.text.neutral.standard)
                }
                .padding(.vertical, 20)
              case .verifyMasterPassword:
                EmptyView()
              }
            }
          )
        }
        .navigationTitle("Bottom Sheet")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(
              action: {},
              label: {
                Image(systemName: "scribble.variable")
              }
            )
          }
        }
      }
    }

    init() {}
  }
#endif
