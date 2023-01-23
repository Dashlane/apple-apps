import Foundation

public struct Quota: Codable {
    
    struct QuotaValues: Codable {
                let max: Int
        
                let remaining: Int
    }
    
    let quota: QuotaValues
}
