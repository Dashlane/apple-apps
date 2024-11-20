import DesignSystem
import Foundation
import SwiftUI

struct ThumbnailsView: View {
  enum ViewConfiguration: String, CaseIterable {
    case singleUser
    case userGroup
    case login
    case secureNote
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["thumbnailsConfiguration"]
    else { return nil }
    return ViewConfiguration(rawValue: configuration)
  }

  var body: some View {
    switch viewConfiguration {
    case .singleUser:
      VStack {
        HStack {
          Thumbnail.User.single(nil)
            .controlSize(.small)
          Thumbnail.User.single(nil)
            .controlSize(.regular)
          Thumbnail.User.single(nil)
            .controlSize(.large)
        }
        HStack {
          Thumbnail.User.single(Image("ProfilePicture"))
            .controlSize(.small)
          Thumbnail.User.single(Image("ProfilePicture"))
            .controlSize(.regular)
          Thumbnail.User.single(Image("ProfilePicture"))
            .controlSize(.large)
        }
      }
    case .userGroup:
      HStack {
        Thumbnail.User.group
          .controlSize(.small)
        Thumbnail.User.group
          .controlSize(.regular)
        Thumbnail.User.group
          .controlSize(.large)
      }
    case .login:
      HStack {
        Thumbnail.login(Image(.profilePicture))
          .controlSize(.small)
        Thumbnail.login(Image(.profilePicture))
          .controlSize(.regular)
        Thumbnail.login(Image(.profilePicture))
          .controlSize(.large)
      }
    case .secureNote:
      HStack {
        Thumbnail.VaultItem.secureNote
          .foregroundStyle(.pink)
          .controlSize(.small)
        Thumbnail.VaultItem.secureNote
          .foregroundStyle(.orange)
          .controlSize(.regular)
        Thumbnail.VaultItem.secureNote
          .foregroundStyle(.yellow)
          .controlSize(.large)
      }
    case .none:
      EmptyView()
    }
  }
}
