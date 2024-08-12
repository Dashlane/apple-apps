import DashTypes

extension PersonalDataContentType {
  private static var sharedPropertyKeys: [String: Set<String>] = [
    "AUTHENTIFIANT": [
      "customFields", "email", "linkedServices", "login", "note", "otpSecret", "otpUrl", "password",
      "secondaryLogin", "title", "url", "useFixedUrl", "userSelectedUrl",
    ],
    "SECRET": ["content", "secured", "title"],
    "SECURENOTE": ["content", "secured", "title"],
  ]

  var sharedPropertyKeys: Set<String> {
    Self.sharedPropertyKeys[self.rawValue, default: []]
  }
  private static var triggerHistoryKeys: [String: Set<String>] = [
    "AUTHENTIFIANT": [
      "email", "login", "note", "otpSecret", "otpUrl", "password", "secondaryLogin", "title", "url",
      "userSelectedUrl",
    ],
    "SECRET": ["content", "title"],
    "SECURENOTE": ["content", "title"],
  ]

  var triggerHistoryKeys: Set<String> {
    Self.triggerHistoryKeys[self.rawValue, default: []]
  }

  private static var deduplicationSignatureKeys: [String: Set<String>] = [
    "ADDRESS": ["addressFull", "attachments", "city", "country", "zipCode"],
    "AUTHENTIFIANT": [
      "attachments", "email", "login", "note", "otpSecret", "otpUrl", "password", "title", "url",
      "useFixedUrl", "userSelectedUrl",
    ],
    "AUTH_CATEGORY": ["attachments", "categoryName"],
    "BANKSTATEMENT": ["attachments", "bankAccountBIC", "bankAccountIBAN"],
    "COLLECTION": ["attachments"],
    "COMPANY": ["attachments", "jobTitle", "name"],
    "DATA_CHANGE_HISTORY": ["attachments"],
    "DRIVERLICENCE": ["attachments", "number"],
    "EMAIL": ["attachments"],
    "FISCALSTATEMENT": ["attachments", "fiscalNumber", "teledeclarantNumber"],
    "GENERATED_PASSWORD": ["attachments", "generatedDate", "password"],
    "IDCARD": ["attachments", "number"],
    "IDENTITY": ["attachments"],
    "MERCHANT": ["attachments"],
    "PASSKEY": ["attachments"],
    "PASSPORT": ["attachments", "number"],
    "PAYMENTMEANS_CREDITCARD": [
      "attachments", "bank", "cardNumber", "expireMonth", "ownerName", "startMonth", "startYear",
    ],
    "PAYMENTMEAN_PAYPAL": ["attachments", "login", "password"],
    "PERSONALWEBSITE": ["attachments", "website"],
    "PHONE": ["attachments", "number"],
    "PURCHASEPAIDBASKET": [
      "attachments", "autoTitle", "comment", "deliveryAddressDescription", "deliveryAddressName",
      "merchantDomain", "paymentMeanDescription", "paymentMeanName", "purchaseDate", "totalAmount",
      "userTitle",
    ],
    "PURCHASE_CATEGORY": ["attachments", "categoryName"],
    "SECRET": ["attachments", "content", "title"],
    "SECUREFILEINFO": ["attachments"],
    "SECURENOTE": ["attachments", "content", "title"],
    "SECURENOTE_CATEGORY": ["attachments", "categoryName"],
    "SECURITYBREACH": ["attachments"],
    "SETTINGS": ["attachments"],
    "SOCIALSECURITYSTATEMENT": ["attachments", "socialSecurityNumber"],
  ]

  var deduplicationSignatureKeys: Set<String> {
    Self.deduplicationSignatureKeys[self.rawValue, default: []]
  }
}
