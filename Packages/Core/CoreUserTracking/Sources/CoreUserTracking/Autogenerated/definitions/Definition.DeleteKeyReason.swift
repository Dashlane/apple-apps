import Foundation

extension Definition {

public enum `DeleteKeyReason`: String, Encodable {
case `newRecoveryKeyGenerated` = "new_recovery_key_generated"
case `recoveryKeyUsed` = "recovery_key_used"
case `settingDisabled` = "setting_disabled"
case `vaultKeyChanged` = "vault_key_changed"
}
}