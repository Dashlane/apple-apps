import Foundation

extension Definition {

public enum `WebauthnExtensionId`: String, Encodable {
case `appid`
case `appidExclude` = "appid_exclude"
case `authnSel` = "authn_sel"
case `credBlob` = "cred_blob"
case `credProps` = "cred_props"
case `credProtect` = "cred_protect"
case `exts`
case `hmacSecret` = "hmac_secret"
case `largeBlob` = "large_blob"
case `largeBlobKey` = "large_blob_key"
case `minPinLength` = "min_pin_length"
case `txAuthGeneric` = "tx_auth_generic"
case `txAuthSimple` = "tx_auth_simple"
case `uvi`
case `uvm`
}
}