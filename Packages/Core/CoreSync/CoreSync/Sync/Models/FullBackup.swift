import Foundation

struct FullBackup: Decodable {
    let content: String?
    let transactions: [BackupEntry]? 

    init(content: String, transactions: [BackupEntry]? = nil) {
        self.content = content
        self.transactions = transactions
    }
}
