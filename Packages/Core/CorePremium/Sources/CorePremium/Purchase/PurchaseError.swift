import DashlaneAPI
import Foundation
import LogFoundation
import StoreKit

@Loggable
public enum PurchaseError: Error {
  public typealias VerificationError = VerificationResult<Transaction>.VerificationError
  case purchaseAlreadyStarted
  @LogPublicPrivacy
  case storeKitVerificationError(VerificationError, transactionId: UInt64)
  @LogPublicPrivacy
  case productPurchaseError(Product.PurchaseError)
  @LogPublicPrivacy
  case storeKitError(StoreKitError)
  case apiError(APIError)
  case invalidReceipt
  case couldNotHashLogin
  @LogPublicPrivacy
  case noAppStoreDiscountAvailable(planName: String)
  case invalidOfferSignature

  case unknown(Error?)
}
