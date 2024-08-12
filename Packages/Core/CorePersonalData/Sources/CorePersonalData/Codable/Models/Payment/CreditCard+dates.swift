import Foundation

extension CreditCard {
  public var expiryDate: Date? {
    guard let year = self.expireYear, let month = self.expireMonth else {
      return nil
    }

    let components = DateComponents(year: year, month: month)
    return Calendar.current.date(from: components)
  }

  public var issuingDate: Date? {
    guard let year = self.startYear, let month = self.startMonth else {
      return nil
    }

    let components = DateComponents(year: year, month: month)
    return Calendar.current.date(from: components)
  }
}
