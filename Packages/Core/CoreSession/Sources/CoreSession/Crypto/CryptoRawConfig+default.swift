import Foundation
import DashTypes
import CyrilKit

extension CryptoRawConfig {
    public static let masterPasswordBasedDefault: CryptoRawConfig =
    CryptoRawConfig(fixedSalt: Data.random(ofSize: 16), parametersHeader: "$1$argon2d$16$3$32768$2$aes256$cbchmac$16$") 
    
    public static let keyBasedDefault: CryptoRawConfig =
    CryptoRawConfig(fixedSalt: nil, parametersHeader: "$1$noderivation$aes256$cbchmac64$16$") 
    
    public static let legacyKeyBasedDefault: CryptoRawConfig =
    CryptoRawConfig(fixedSalt: nil, parametersHeader: "$1$noderivation$aes256$cbchmac$16$") 
}

