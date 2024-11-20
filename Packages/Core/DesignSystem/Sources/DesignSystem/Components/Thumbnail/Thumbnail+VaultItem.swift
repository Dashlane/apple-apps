import Foundation
import SwiftUI

extension Thumbnail {

  public enum VaultItem: View {
    case secureNote
    case passkey
    case paymentCard
    case bankAccount
    case idCard
    case socialSecurityCard
    case driversLicense
    case passport
    case taxNumber
    case address
    case company
    case email
    case name
    case phoneNumber
    case website
    case attachment

    public var body: some View {
      BaseThumbnail {
        switch self {
        case .secureNote:
          SquircleIconThumbnailContentView(Image.ds.item.secureNote.outlined)
        case .passkey:
          SquircleIconThumbnailContentView(Image.ds.passkey.outlined)
        case .paymentCard:
          SquircleIconThumbnailContentView(Image.ds.item.payment.outlined)
        case .bankAccount:
          SquircleIconThumbnailContentView(Image.ds.item.bankAccount.outlined)
        case .idCard:
          SquircleIconThumbnailContentView(Image.ds.item.id.outlined)
        case .socialSecurityCard:
          SquircleIconThumbnailContentView(Image.ds.item.socialSecurity.outlined)
        case .driversLicense:
          SquircleIconThumbnailContentView(Image.ds.item.driversLicense.outlined)
        case .passport:
          SquircleIconThumbnailContentView(Image.ds.item.passport.outlined)
        case .taxNumber:
          SquircleIconThumbnailContentView(Image.ds.item.taxNumber.outlined)
        case .address:
          SquircleIconThumbnailContentView(Image.ds.home.outlined)
        case .company:
          SquircleIconThumbnailContentView(Image.ds.item.company.outlined)
        case .email:
          SquircleIconThumbnailContentView(Image.ds.item.email.outlined)
        case .name:
          SquircleIconThumbnailContentView(Image.ds.item.personalInfo.outlined)
        case .phoneNumber:
          SquircleIconThumbnailContentView(Image.ds.item.phoneMobile.outlined)
        case .website:
          SquircleIconThumbnailContentView(Image.ds.web.outlined)
        case .attachment:
          SquircleIconThumbnailContentView(Image.ds.attachment.outlined)
        }
      }
    }
  }
}

#Preview("Secure Note") {
  HStack {
    Thumbnail.VaultItem.secureNote
      .controlSize(.mini)
    Thumbnail.VaultItem.secureNote
      .foregroundStyle(.yellow)
      .controlSize(.regular)
    Thumbnail.VaultItem.secureNote
      .foregroundStyle(.pink)
      .controlSize(.large)
  }
}

#Preview("Payment Card") {
  HStack {
    Thumbnail.VaultItem.paymentCard
      .controlSize(.mini)
    Thumbnail.VaultItem.paymentCard
      .foregroundStyle(.mint)
      .controlSize(.regular)
    Thumbnail.VaultItem.paymentCard
      .foregroundStyle(.blue)
      .controlSize(.large)
  }
}
