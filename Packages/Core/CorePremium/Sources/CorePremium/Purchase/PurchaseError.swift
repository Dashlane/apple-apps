import DashlaneAPI
import Foundation
import StoreKit

public enum PurchaseError: Error {
  public typealias VerificationError = VerificationResult<Transaction>.VerificationError
  case purchaseAlreadyStarted
  case storeKitVerificationError(VerificationError, transactionId: UInt64)
  case productPurchaseError(Product.PurchaseError)
  case storeKitError(StoreKitError)
  case apiError(APIError)
  case invalidReceipt
  case couldNotHashLogin
  case noAppStoreDiscountAvailable(planName: String)
  case invalidOfferSignature

  case unknown(Error?)
}
