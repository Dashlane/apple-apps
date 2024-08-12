struct PersonalDataSpec {
  static var keys: [String: Set<String>] = [
    "ADDRESS": [
      "addressFull", "addressName", "anonId", "attachments", "building", "city", "country",
      "creationDatetime", "digitCode", "door", "floor", "id", "isFavorite", "lastBackupTime",
      "linkedPhone", "localeFormat", "personalNote", "receiver", "spaceId", "stairs", "state",
      "stateLevel2", "stateNumber", "streetName", "streetNumber", "streetTitle",
      "userModificationDatetime", "zipCode",
    ],
    "AUTHENTIFIANT": [
      "anonId", "appMetaData", "appMetaDataLastUpdate", "attachments", "autoLogin", "autoProtected",
      "category", "checked", "creationDatetime", "customFields", "email", "id", "isFavorite",
      "lastBackupTime", "lastUse", "linkedServices", "localeFormat", "login",
      "modificationDatetime", "note", "numberUse", "otpSecret", "otpUrl", "password",
      "personalNote", "secondaryLogin", "sharedObject", "spaceId", "status", "strength",
      "subdomainOnly", "title", "trustedUrlGroup", "url", "useFixedUrl", "userModificationDatetime",
      "userSelectedUrl",
    ],
    "AUTH_CATEGORY": [
      "anonId", "attachments", "categoryName", "creationDatetime", "id", "isFavorite",
      "lastBackupTime", "localeFormat", "personalNote", "spaceId", "userModificationDatetime",
    ],
    "BANKSTATEMENT": [
      "anonId", "attachments", "bankAccountBIC", "bankAccountBank", "bankAccountIBAN",
      "bankAccountName", "bankAccountOwner", "creationDatetime", "id", "isFavorite",
      "lastBackupTime", "localeFormat", "personalNote", "spaceId", "userModificationDatetime",
    ],
    "COLLECTION": [
      "anonId", "attachments", "creationDatetime", "id", "isFavorite", "lastBackupTime",
      "localeFormat", "name", "personalNote", "spaceId", "userModificationDatetime", "vaultItems",
    ],
    "COMPANY": [
      "anonId", "attachments", "creationDatetime", "id", "isFavorite", "jobTitle", "lastBackupTime",
      "localeFormat", "nafCode", "name", "personalNote", "sirenNumber", "siretNumber", "spaceId",
      "tvaNumber", "userModificationDatetime",
    ],
    "DATA_CHANGE_HISTORY": [
      "anonId", "attachments", "changeSets", "creationDatetime", "id", "isFavorite",
      "lastBackupTime", "localeFormat", "objectId", "objectTitle", "objectType", "personalNote",
      "spaceId", "userModificationDatetime",
    ],
    "DRIVERLICENCE": [
      "anonId", "attachments", "creationDatetime", "dateOfBirth", "deliveryDate", "expireDate",
      "fullname", "id", "isFavorite", "lastBackupTime", "linkedIdentity", "localeFormat", "number",
      "personalNote", "sex", "spaceId", "state", "userModificationDatetime",
    ],
    "EMAIL": [
      "anonId", "attachments", "creationDatetime", "email", "emailName", "id", "isFavorite",
      "lastBackupTime", "localeFormat", "personalNote", "spaceId", "type",
      "userModificationDatetime",
    ],
    "FISCALSTATEMENT": [
      "anonId", "attachments", "creationDatetime", "fiscalNumber", "fullname", "id", "isFavorite",
      "lastBackupTime", "linkedIdentity", "localeFormat", "personalNote", "spaceId",
      "teledeclarantNumber", "userModificationDatetime",
    ],
    "GENERATED_PASSWORD": [
      "anonId", "attachments", "authId", "creationDatetime", "domain", "generatedDate", "id",
      "isFavorite", "lastBackupTime", "localeFormat", "password", "personalNote", "platform",
      "spaceId", "userModificationDatetime",
    ],
    "IDCARD": [
      "anonId", "attachments", "creationDatetime", "dateOfBirth", "deliveryDate", "expireDate",
      "fullname", "id", "isFavorite", "lastBackupTime", "linkedIdentity", "localeFormat", "number",
      "personalNote", "sex", "spaceId", "userModificationDatetime",
    ],
    "IDENTITY": [
      "anonId", "attachments", "birthDate", "birthPlace", "creationDatetime", "firstName", "id",
      "isFavorite", "lastBackupTime", "lastName", "lastName2", "localeFormat", "middleName",
      "personalNote", "pseudo", "spaceId", "title", "type", "userModificationDatetime",
    ],
    "MERCHANT": [
      "anonId", "attachments", "creationDatetime", "domain", "id", "isFavorite", "lastBackupTime",
      "localeFormat", "personalNote", "spaceId", "title", "userModificationDatetime", "website",
    ],
    "PASSKEY": [
      "anonId", "attachments", "counter", "creationDatetime", "credentialId", "id", "isFavorite",
      "itemName", "keyAlgorithm", "lastBackupTime", "localeFormat", "note", "personalNote",
      "privateKey", "rpId", "rpName", "spaceId", "userDisplayName", "userHandle",
      "userModificationDatetime",
    ],
    "PASSPORT": [
      "anonId", "attachments", "creationDatetime", "dateOfBirth", "deliveryDate", "deliveryPlace",
      "expireDate", "fullname", "id", "isFavorite", "lastBackupTime", "linkedIdentity",
      "localeFormat", "number", "personalNote", "sex", "spaceId", "userModificationDatetime",
    ],
    "PAYMENTMEANS_CREDITCARD": [
      "anonId", "attachments", "bank", "cCNote", "cardNumber", "cardNumberLastDigits", "color",
      "creationDatetime", "expireMonth", "expireYear", "id", "isFavorite", "issueNumber",
      "lastBackupTime", "linkedBillingAddress", "localeFormat", "name", "ownerName", "personalNote",
      "securityCode", "spaceId", "startMonth", "startYear", "type", "userModificationDatetime",
    ],
    "PAYMENTMEAN_PAYPAL": [
      "anonId", "attachments", "creationDatetime", "id", "isFavorite", "lastBackupTime",
      "localeFormat", "login", "name", "password", "personalNote", "spaceId",
      "userModificationDatetime",
    ],
    "PERSONALWEBSITE": [
      "anonId", "attachments", "creationDatetime", "id", "isFavorite", "lastBackupTime",
      "localeFormat", "name", "personalNote", "spaceId", "userModificationDatetime", "website",
    ],
    "PHONE": [
      "anonId", "attachments", "creationDatetime", "id", "isFavorite", "lastBackupTime",
      "localeFormat", "number", "numberInternational", "numberNational", "personalNote",
      "phoneName", "spaceId", "type", "userModificationDatetime",
    ],
    "PURCHASEPAIDBASKET": [
      "alreadyClient", "anonId", "articles", "attachments", "autoTitle",
      "billingAddressDescription", "billingAddressName", "category", "comment", "creationDatetime",
      "currency", "deliveryAddressDescription", "deliveryAddressName", "deliveryType",
      "fullScreenFiles", "id", "isFavorite", "lastBackupTime", "localeFormat", "merchantDomain",
      "paymentMeanDescription", "paymentMeanName", "personalNote", "purchaseDate", "spaceId",
      "totalAmount", "userModificationDatetime", "userTitle",
    ],
    "PURCHASE_CATEGORY": [
      "anonId", "attachments", "categoryName", "creationDatetime", "id", "isFavorite",
      "lastBackupTime", "localeFormat", "personalNote", "spaceId", "userModificationDatetime",
    ],
    "SECRET": [
      "anonId", "attachments", "content", "creationDatetime", "id", "isFavorite", "lastBackupTime",
      "localeFormat", "personalNote", "secured", "spaceId", "title", "userModificationDatetime",
    ],
    "SECUREFILEINFO": [
      "anonId", "attachments", "creationDatetime", "cryptoKey", "downloadKey", "filename", "id",
      "isFavorite", "lastBackupTime", "localSize", "localeFormat", "owner", "personalNote",
      "remoteSize", "spaceId", "type", "userModificationDatetime", "version",
    ],
    "SECURENOTE": [
      "anonId", "attachments", "category", "content", "creationDate", "creationDatetime", "id",
      "isFavorite", "lastBackupTime", "localeFormat", "personalNote", "secured", "spaceId", "title",
      "type", "updateDate", "userModificationDatetime",
    ],
    "SECURENOTE_CATEGORY": [
      "anonId", "attachments", "categoryName", "creationDatetime", "id", "isFavorite",
      "lastBackupTime", "localeFormat", "personalNote", "spaceId", "userModificationDatetime",
    ],
    "SECURITYBREACH": [
      "anonId", "attachments", "breachId", "content", "contentRevision", "creationDatetime", "id",
      "isFavorite", "lastBackupTime", "leakedPasswords", "localeFormat", "personalNote", "spaceId",
      "status", "userModificationDatetime",
    ],
    "SETTINGS": [
      "accountCreationDatetime", "accountRecoveryKey", "accountRecoveryKeyId", "anonId",
      "anonymousUserId", "attachments", "autoLogin", "autofillSettings", "autologoutInactivity",
      "autologoutInactivityDuration", "autologoutInactivityException", "banishedUrlsList",
      "contactsViewCriteria", "countSupportUsPopupShown", "creationDatetime",
      "credentialsViewCriteria", "cryptoFixedSalt", "cryptoUserPayload",
      "dashlane6PresentationShown", "dashlaneName", "defaultScreenCivilInformationEnded",
      "defaultScreenContactInformationEnded", "defaultScreenEmergencyEnded",
      "defaultScreenPaymentMeansEnded", "defaultScreenPurchasesAllEnded",
      "defaultScreenSecuredNotesEnded", "defaultScreenSharingEnded",
      "defaultScreenWebPasswordsEnded", "deliveryType", "disabledDomainsAutologinList",
      "disabledDomainsList", "disabledUrlsAutologinList", "disabledUrlsList",
      "generatorDefaultAvoidAmbiguousChars", "generatorDefaultDigits", "generatorDefaultLetters",
      "generatorDefaultSize", "generatorDefaultSymbols", "gettingStartedPasswordsEnded",
      "gettingStartedPasswordsImported", "gettingStartedPersonaldataEnded",
      "gettingStartedPopoverEnded", "gettingStartedSecurityDashboardEnded",
      "gettingStartedStepNewStatus_1", "gettingStartedStepNewStatus_3", "gettingStartedVaultEnded",
      "hotspotCredentialAddComplete", "hotspotCredentialPasswordChangerComplete",
      "hotspotCredentialShareComplete", "hotspotCredentialSortComplete",
      "hotspotSecureNoteShareComplete", "hotspotTeamSpacesChangeVaultComplete",
      "hotspotTeamSpacesOtherVaultComplete", "iDsSortCriteria", "iDsViewCriteria", "id",
      "isFavorite", "languageNoticesShown", "lastBackupTime", "localeFormat",
      "mobileAppLinkLastShownDate", "mustFlushCreditCardsDetailsLogs",
      "mustFlushPasswordsDetailsLogs", "mustFlushPurchasesDetailsLogs2", "notificationPasswords",
      "notificationPersonaldata", "notificationPurchases", "notificationSecurity",
      "notificationSync", "oTPActivation", "passwordChangerPublicAccessShown",
      "passwordChangerSignupForBetaShown", "passwordLeakAnonymousId",
      "passwordLeakLastCheckedTimestamp", "paymentsSortCriteria", "paymentsViewCriteria",
      "personalNote", "protectIDs", "protectPasswords", "protectPayments", "proxyActivation",
      "prremiumShowBadges", "purchaseDefaultAddress", "purchaseDefaultEmail",
      "purchaseDefaultPaymentMean", "purchaseDefaultPhone", "purchaseGeneratePassword",
      "purchasesSortCriteria", "purchasesViewCriteria", "realLogin", "recoveryHash", "recoveryKey",
      "recoveryOptIn", "renewalNoticeExpiredShown", "renewalNoticeFifteenDaysShown",
      "renewalNoticeFiveDaysShown", "renewalNoticeLastDayShown", "renewalNoticeThirtyDaysShown",
      "renewalNotificationExpiredLastDate", "renewalNotificationWillExpireLastDate", "richIcons",
      "rsaPrivateKeys", "rsaPublicKey", "saveDataCapturedAutomatically", "saveDataCapturedEnabled",
      "securedDataAutofillCreditcard", "securedDataShowCreditcard", "securedDataShowIDs",
      "securedDataShowPassword", "securedDataShowScreenshots", "securityEmail", "securityPhone",
      "sharingFacebookAccessToken", "sharingFacebookSessionSaved", "sharingFacebookUid",
      "sharingTwitterAccessToken", "sharingTwitterAccessTokenSecret", "sharingTwitterSessionSaved",
      "showAddObjects", "showImpalas", "showLogoutConfirmation", "showSystemTray", "sortCriteria",
      "spaceAnonIds", "spaceId", "spaceSettingsPresentationShown", "spacesPresentationShown",
      "spacesRevokedShown", "syncBackup", "syncBackupCreditCardsCCV", "syncBackupCreditCardsNumber",
      "syncBackupPasswords", "syncBackupPersonaldata", "syncBackupPurchase", "syncTimer",
      "threePointZeroPresentationShown", "usagelogToken", "userModificationDatetime",
      "vaultSortCriteria", "vaultViewCriteria",
    ],
    "SOCIALSECURITYSTATEMENT": [
      "anonId", "attachments", "creationDatetime", "dateOfBirth", "id", "isFavorite",
      "lastBackupTime", "linkedIdentity", "localeFormat", "personalNote", "sex",
      "socialSecurityFullname", "socialSecurityNumber", "spaceId", "userModificationDatetime",
    ],
  ]

  static var jsonKeys: [String: Set<String>] = [
    "ADDRESS": ["attachments"],
    "AUTHENTIFIANT": ["appMetaData", "attachments", "customFields", "linkedServices"],
    "AUTH_CATEGORY": ["attachments"],
    "BANKSTATEMENT": ["attachments"],
    "COLLECTION": ["attachments"],
    "COMPANY": ["attachments"],
    "DATA_CHANGE_HISTORY": ["attachments"],
    "DRIVERLICENCE": ["attachments"],
    "EMAIL": ["attachments"],
    "FISCALSTATEMENT": ["attachments"],
    "GENERATED_PASSWORD": ["attachments"],
    "IDCARD": ["attachments"],
    "IDENTITY": ["attachments"],
    "MERCHANT": ["attachments"],
    "PASSKEY": ["attachments"],
    "PASSPORT": ["attachments"],
    "PAYMENTMEANS_CREDITCARD": ["attachments"],
    "PAYMENTMEAN_PAYPAL": ["attachments"],
    "PERSONALWEBSITE": ["attachments"],
    "PHONE": ["attachments"],
    "PURCHASEPAIDBASKET": ["attachments"],
    "PURCHASE_CATEGORY": ["attachments"],
    "SECRET": ["attachments"],
    "SECUREFILEINFO": ["attachments"],
    "SECURENOTE": ["attachments"],
    "SECURENOTE_CATEGORY": ["attachments"],
    "SECURITYBREACH": ["attachments"],
    "SETTINGS": ["attachments", "autofillSettings"],
    "SOCIALSECURITYSTATEMENT": ["attachments"],
  ]

  static var triggerHistoryKeys: [String: Set<String>] = [
    "AUTHENTIFIANT": [
      "email", "login", "note", "otpSecret", "otpUrl", "password", "secondaryLogin", "title", "url",
      "userSelectedUrl",
    ],
    "SECRET": ["content", "title"],
    "SECURENOTE": ["content", "title"],
  ]
}